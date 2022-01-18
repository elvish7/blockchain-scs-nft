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
        string[] founderKeys;
        uint256[] certificates;
    }
 
    mapping(uint256 => Certificate) private nftOwner;
    mapping(string => Company) private hub;
    uint256 nftNum;


    constructor() public ERC1155("https://abcoathup.github.io/SampleERC1155/api/token/{id}.json") {
        nftNum = 0;
    }

    modifier exist(string memory cName) {
        require(hub[cName].founderKeys.length != 0, "company doesn't exist");
        _;
    }

    // for those companies using this system for the first time
    function register(string memory cName, uint256 date, uint256 amount, string[] memory keys) public {
        Company memory c;
        c.name = cName;
        c.foundingDate = date;
        c.originShares = amount;
        c.keysLen = keys.length;
        c.founderKeys = keys;

        hub[cName] = c;
    }

    // issue new certificate NFT
    function issuing(string memory cName, uint256 amount, string[] memory keys, address receiver) public exist(cName) {
        require(keys.length == hub[cName].keysLen, "key is wrong");

        for (uint j=0; j<keys.length; j++) {
            require(keccak256(bytes(hub[cName].founderKeys[j])) == keccak256(bytes(keys[j])), 
                "key is wrong");
        }

        Certificate memory cert;
        cert.id = nftNum;
        cert.amount = amount;
        cert.owner = receiver;
        cert.companyName = cName;
        nftOwner[nftNum] = cert;

        hub[cName].certificates.push(nftNum);

        _mint(receiver, nftNum, 1, "");
        nftNum += 1;
    }  

    // burn the certificate 
    function redemption(address owner, uint256 id) public {
        burn(owner, id);
    }

    function burn(address owner, uint256 id) private {
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

        transacting(owner, address(0), id, 1);
    }

    // burn NFT and split it into 2 NFTs 
    function splitCertificate(address burner, uint256 id, address r1, address r2, uint256 amount, string[] memory keys) public {
        require(r1 != address(0) && r2 != address(0), "transfor to zero address");

        Certificate memory cert = nftOwner[id];
        burn(burner, id);
        issuing(cert.companyName, amount, keys, r1);
        issuing(cert.companyName, cert.amount - amount, keys, r2);
    }


    // transfer certificate to other people
    function transacting(address from, address to, uint256 id, uint256 amount) public {
        require(nftOwner[id].owner == from, "not owner of this token");
        
        nftOwner[id].owner = to;
        TransferSingle(_msgSender(), from, to, id, amount);
    }

    // lookup company's information, including name, foundingDate, originShares, certificates
    function lookup(string memory cName) 
      public view exist(cName) returns (string memory, uint256, uint256, Certificate[] memory) {
        Company memory comp = hub[cName];
        uint256[] memory cert = hub[cName].certificates;
        Certificate[] memory c = new Certificate[](cert.length);
        for (uint i=0; i<cert.length; i++) {
            c[i] = nftOwner[cert[i]];
        }

        return (cName, comp.foundingDate, comp.originShares, c);
    }
}