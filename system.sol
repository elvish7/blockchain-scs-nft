// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/token/ERC1155/ERC1155.sol";

contract SCS is ERC1155 {
    struct Certificate {
        uint256 id;
        uint256 amount;
        address owner;
        address companyAdd;
    }
    struct Company {
        string name;
        uint256 foundingDate;
        uint256 originShares;
        address addr;
        uint keysLen;
        mapping(string => bool) founderKeys;
        uint256[] certificates;
    }

    mapping(uint256 => Certificate) public nftOwner;
    mapping(address => Company) public hub;
    uint256 nftNum;


    constructor() public ERC1155("") {
        nftNum = 0;
    }

    // for those companies using this system for the first time
    function register(string memory cName, uint256 date, uint256 amount, string[] memory keys) private {
        address add = msg.sender;
        Company memory c;
        c.name = cName;
        c.foundingDate = date;
        c.originShares = amount;
        c.addr = add;
        c.keysLen = keys.length;
        for (uint i=0; i<keys.length; i++) {
            c.founderKeys[keys[i]] = true;
        }

        hub[add] = c;
    }

    // issue new certificate NFT
    function issuing(uint256 amount, string[] memory keys, address receiver) private {
        address add = msg.sender;
        require(keys.length == hub[add].keysLen, "key is wrong");

        for (uint j=0; j<keys.length; j++) {
            require(hub[add].founderKeys[keys[j]] != false, "key is wrong");
        }

        Certificate memory cert;
        cert.id = nftNum;
        cert.amount = amount;
        cert.owner = receiver;
        cert.companyAdd = add;
        nftOwner[receiver] = cert;

        hub[add].certificates.push(nftNum);

        _mint(add, nftNum, 1, "");
        nftNum += 1;
        transacting(add, receiver, nftNum-1, 1);
    }  

    // burn the certificate 
    function burn(address owner, uint256 id) private {
        require(owner != address(0), "burn from zero address");

        Certificate memory cert = nftOwner[id];
        Company memory c = hub[cert.companyAdd];
        require(owner == cert.owner, "Not owner of this token");

        removeCert(id, c);
        transacting(owner, address(0), id, 1);
    }

    // burn NFT and split it into 2 NFTs 
    function splitCertificate(address burner, uint256 id, address r1, address r2, uint256 amount, string[] memory keys) private {
        require(r1 != address(0) && r2 != address(0), "transfor to zero address");

        Certificate memory cert = nftOwner[id];
        burn(burner, id);
        issuing(amount, keys, r1);
        issuing(cert.amount - amount, keys, r2);
    }


    // transfer certificate to other people
    function transacting(address from, address to, uint256 id, uint256 amount) private {
        safeTransferFrom(from, to, id, amount, "");
    }


    function removeCert(uint256 id, Company memory c) private {
        uint index = 0;
        uint len = c.certificates.length;
        for (uint i=0; i<len; i++) {
            if (c.certificates[i] == id) {
                index = i;
            }
        }

        c.certificates[index] = c.certificates[len-1];
        delete c.certificates[len-1];
    }
}