// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract AirdropNFT is ERC721Enumerable {
    uint256 tokenId = 0;

    constructor() ERC721("tNFT", "tNFT") {
        for (uint i = 0; i < 50; i++) {
            mintTo(msg.sender);
        }
    }

    function mint() public {
        tokenId++;
        _mint(msg.sender, tokenId);
    }

    function mintTo(address to) public {
        tokenId++;
        _mint(to, tokenId);
    }
}
