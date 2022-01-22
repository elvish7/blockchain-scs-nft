// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/token/ERC1155/ERC1155.sol";

contract SCS is ERC1155 {
    struct Certificate {
        uint256 id;
        uint256 amount;
        address owner;
        string companyName;
    }
    
    struct Company {
        string name;
        uint256 foundingDate;
        uint256 originShares;
        uint keysLen;
        address[] founderKeys;
        uint256[] certificates;
    }
    
    struct SplitVote {
        uint256 id;
        uint256 burnID;
        address r1;
        address r2;
        uint256 amount;
        address[] founders;
    }
    
    struct Vote {
        uint256 id;
        string name;
        address receiver;
        uint256 amount;
        address[] founders;
    }

    event getVoteDetail(uint id, address[] founders);

    mapping(uint256 => SplitVote) private splitList;
    mapping(uint256 => Vote) private waitingList; 
    mapping(uint256 => Certificate) private nftOwner;
    mapping(string => Company) private hub;
    uint256 nftID;
    uint256 voteID;
    uint256 splitID;

    constructor() public ERC1155("https://elvish7.github.io/blockchain-scs-nft/token/0.json") {
        nftID = 0;
        voteID = 0;
        splitID = 0;
    }

    modifier exist(string memory cName) {
        require(hub[cName].founderKeys.length != 0, "company doesn't exist");
        _;
    }

    function lookList(uint256 id) public view returns (Vote memory) {
        return waitingList[id];
    }

    function lookSplitList(uint256 id) public view returns (SplitVote memory) {
        return splitList[id];
    }

    // for those companies using this system for the first time
    function register(string memory cName, uint256 date, uint256 amount, address[] memory founders) public {
        require(founders.length != 0, "no founder");
        require(hub[cName].founderKeys.length == 0, "this name has been used");

        Company memory c;
        c.name = cName;
        c.foundingDate = date;
        c.originShares = amount;
        c.keysLen = founders.length;
        c.founderKeys = founders;

        hub[cName] = c;
    }

    function launchVote(string memory cName, address receiver, uint256 amount) 
      public exist(cName) {
        require(receiver != address(0), "launch to zero address");

        Vote memory v;
        v.id = voteID;
        v.name = cName;
        v.receiver = receiver;
        v.amount = amount;
        v.founders = hub[cName].founderKeys;
        
        waitingList[voteID] = v;
        voteID++;

        emit getVoteDetail(voteID-1, v.founders);
        // return voteID-1;
    }

    function launchSplitVote(uint256 id, address r1, address r2, uint256 amount) public {
        require(nftOwner[id].owner != address(0), "NFT doesn't exist");
        require(nftOwner[id].owner == msg.sender, "not owner of this token");
        require(r1 != address(0) && r2 != address(0), "split to zero address");
        require(nftOwner[id].amount >= amount, "origin share is smaller than desired share");

        SplitVote memory v;
        Company memory c = hub[nftOwner[id].companyName];
        v.id = splitID;
        v.burnID = id;
        v.r1 = r1;
        v.r2 = r2;
        v.amount = amount;
        v.founders = c.founderKeys;

        splitList[splitID] = v;
        splitID++;

        emit getVoteDetail(splitID-1, v.founders);
        // return splitID-1;
      }

    function sign(uint256 id) public {
        Vote memory v = waitingList[id];
        require(v.founders.length != 0, "vote doesn't exist");

        address signer = msg.sender;
        for (uint i=0; i<v.founders.length; i++) {
            if (v.founders[i] == signer) {
                waitingList[id].founders[i] = waitingList[id].founders[v.founders.length-1];
                waitingList[id].founders.pop();
                if (waitingList[id].founders.length == 0) {
                    issuing(v.name, v.amount, v.receiver);
                }
                emit getVoteDetail(id, waitingList[id].founders);
                return;
            }
        }
        require(1 == 0, "you're not founder or you've signed");
    }

    function signSplit(uint256 id) public {
        SplitVote memory v = splitList[id];
        require(v.founders.length != 0, "vote doesn't exist");

        address signer = msg.sender;
        for (uint i=0; i<v.founders.length; i++) {
            if (v.founders[i] == signer) {
                splitList[id].founders[i] = splitList[id].founders[v.founders.length-1];
                splitList[id].founders.pop();
                if (splitList[id].founders.length == 0) {
                    splitCertificate(v);
                }
                emit getVoteDetail(id, splitList[id].founders);
                return;
            }
        }
        require(1 == 0, "you're not founder or you've signed");    
    }

    // issue new certificate NFT
    function issuing(string memory cName, uint256 amount, address receiver) private {
        //require(hub[cName].founderKeys.length != 0, "this company doesn't exist");
        //require(receiver != address(0), "receiver is zero address");

        Certificate memory cert;
        cert.id = nftID;
        cert.amount = amount;
        cert.owner = receiver;
        cert.companyName = cName;
        nftOwner[nftID] = cert;

        hub[cName].certificates.push(nftID);

        _mint(receiver, nftID, 1, "");
        nftID += 1;
    }

    // burn the certificate 
    function redemption(address owner, uint256 id) public {
        burn(owner, id);
    }

    function burn(address owner, uint256 id) private {
        require(nftOwner[id].owner != address(0), "NFT doesn't exist");
        require(owner != address(0), "burn from zero address");

        Certificate memory cert = nftOwner[id];
        require(owner == cert.owner, "Not owner of this token");

        uint index = 0;
        uint len = hub[cert.companyName].certificates.length;
        for (uint i=0; i<len; i++) {
            if (hub[cert.companyName].certificates[i] == id) {
                index = i;
            }
        }
        hub[cert.companyName].certificates[index] = hub[cert.companyName].certificates[len-1];
        hub[cert.companyName].certificates.pop();

        transacting(owner, address(0), id);
    }

    // burn NFT and split it into 2 NFTs 
    function splitCertificate(SplitVote memory v) private {
        Certificate memory cert = nftOwner[v.burnID];
        burn(cert.owner, cert.id);
        issuing(cert.companyName, v.amount, v.r1);
        issuing(cert.companyName, cert.amount - v.amount, v.r2);
    }


    // transfer certificate to other people
    function transacting(address from, address to, uint256 id) public {
        require(nftOwner[id].owner == from, "not owner of this token");
        
        nftOwner[id].owner = to;
        TransferSingle(_msgSender(), from, to, id, 1);
    }

    // lookup company's information, including name, foundingDate, originShares, certificates
    function lookup(string memory cName) 
      public view exist(cName)
      returns (string memory, uint256, uint256, Certificate[] memory) {

        Company memory comp = hub[cName];
        uint256[] memory cert = hub[cName].certificates;
        Certificate[] memory c = new Certificate[](cert.length);
        for (uint i=0; i<cert.length; i++) {
            c[i] = nftOwner[cert[i]];
        }

        return (cName, comp.foundingDate, comp.originShares, c);
    }
}