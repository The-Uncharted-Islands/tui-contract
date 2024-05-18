// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TheUnchartedIslands is ERC721Enumerable, Ownable {

    mapping(address => uint256) public mintCount;
    mapping(address => uint256) public _nonces;

    address public signerAddress;
    uint256 public maxMintSupply = 10000;

    string public baseTokenURI;

    constructor() ERC721("TheUnchartedIslands", "Island") {}

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function setMaxMintSupply(uint256 _maxMintSupply) external onlyOwner {
        maxMintSupply = _maxMintSupply;
    }

    function setSignerAddress(address _signerAddress) external onlyOwner {
        signerAddress = _signerAddress;
    }

    function mint(bytes memory signature, uint256 nonce) external payable {
        require(totalSupply() < maxMintSupply, "Exceed total supply");
        require(mintCount[msg.sender] < 3, "Exceed mint count");
        mintCount[msg.sender] = mintCount[msg.sender] + 1;

        require(
            checkSignature(signature, msg.sender, nonce),
            "Signature error"
        );
        // nonce uncheck
        _mint(msg.sender, totalSupply() + 1);
    }

    function mintByOwner(address to) public onlyOwner {
        _mint(to, totalSupply() + 1);
    }

    function withdrawEth(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "balance error");
        payable(to).transfer(balance);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        // _requireMinted(tokenId);

        return
            bytes(baseTokenURI).length > 0
                ? string.concat(baseTokenURI, Strings.toString(tokenId))
                : "";
    }

    function checkSignature(
        bytes memory signature,
        address user,
        uint nonce
    ) public view returns (bool) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(address(this), user, nonce, block.chainid)
        );

        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(
            messageHash
        );

        return ECDSA.recover(ethSignedMessageHash, signature) == signerAddress;
    }
}
