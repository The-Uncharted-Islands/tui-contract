//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract AssetsPool is
    Ownable,
    IERC721Receiver,
    ReentrancyGuard
{
    using SafeMath for uint256;
    using Address for address;
    using ECDSA for bytes32;

    mapping(address => bool) public operators;

    address public signerAddress;

    // user - token - amount
    mapping(address => mapping(address => uint256)) public lockTokens;
    // user - nft - token id
    mapping(address => mapping(address => uint256[])) public lockNfts;

    mapping(uint256 => bool) public nonces;

    event DepositNFT(address indexed user, address nft, uint256[] tokenIds);
    event WithdrawNFT(address indexed user, address nft, uint256[] tokenIds);
    event TransferNFT(address indexed user, address nft, uint256[] tokenIds);

    event DepositToken(address indexed user, address token, uint256 amount);
    event WithdrawToken(address indexed user, address token, uint256 amount);
    event TransferToken(address indexed user, address token, uint256 amount);

    event DepositETH(address indexed user, uint256 amount);
    event WithdrawETH(address indexed user, uint256 amount);
    event TransferETH(address indexed user, uint256 amount);

    modifier onlyOperator() {
        require(operators[msg.sender], "Error: operator not allowed!");
        _;
    }

    function depositToken(
        address tokenAddress,
        uint256 amount
    ) external nonReentrant {
        require(amount != 0, "amount error");
        require(tokenAddress != address(0), "token error");

        IERC20 token = IERC20(tokenAddress);

        lockTokens[msg.sender][tokenAddress] =
            lockTokens[msg.sender][tokenAddress] +
            amount;
        token.transferFrom(msg.sender, address(this), amount);

        emit DepositToken(msg.sender, tokenAddress, amount);
    }

    function transferToken(
        address user,
        address tokenAddress,
        uint256 amount
    ) external nonReentrant onlyOperator {
        require(amount != 0, "amount error");
        require(tokenAddress != address(0), "token error");
        require(user != address(0), "user error");
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "balance error");

        // lockTokens[msg.sender][tokenAddress] = lockTokens[msg.sender][tokenAddress] - amount;
        token.transfer(user, amount);

        emit TransferToken(msg.sender, tokenAddress, amount);
    }

    // -------------

    function depositETH() external payable nonReentrant {
        require(msg.value != 0, "value error");

        lockTokens[msg.sender][address(0)] =
            lockTokens[msg.sender][address(0)] +
            msg.value;

        emit DepositETH(msg.sender, msg.value);
    }

    // function transferETH(
    //     address user,
    //     uint256 amount
    // ) external nonReentrant onlyOperator {
    //     require(amount != 0, "amount error");
    //     require(user != address(0), "user error");
    //     require(!user.isContract(), "user error");
    //     require(address(this).balance >= amount, "balance error");

    //     lockTokens[msg.sender][address(0)] =
    //         lockTokens[msg.sender][address(0)] -
    //         amount;
    //     payable(user).transfer(amount);

    //     emit TransferETH(msg.sender, amount);
    // }

    function withdrawETH(
        uint256 amount,
        uint256 nonce,
        uint256 expired,
        bytes calldata signature
    ) external nonReentrant {
        require(
            checkSignature(signature, msg.sender, nonce, expired, amount, 0),
            "signature error"
        );
        require(amount != 0, "amount error");
        require(!msg.sender.isContract(), "user error");
        require(address(this).balance >= amount, "balance error");
        // nonce 
        require(nonces[nonce] == false, "nonce error");
        nonces[nonce] == true;

        lockTokens[msg.sender][address(0)] =
            lockTokens[msg.sender][address(0)] -
            amount;
        payable(msg.sender).transfer(amount);

        emit WithdrawETH(msg.sender, amount);
    }

    // ------------------
    function depositNFT(
        address nftAddress,
        uint256[] memory tokenIds
    ) external nonReentrant {
        require(tokenIds.length != 0, "length error");
        require(nftAddress != address(0), "nft error");
        uint256 tokenId;
        IERC721 nft = IERC721(nftAddress);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            lockNfts[msg.sender][nftAddress].push(tokenId);
        }
        emit DepositNFT(msg.sender, nftAddress, tokenIds);
    }

    function transferNFT(
        address nftAddress,
        uint256[] memory tokenIds
    ) external nonReentrant onlyOperator {
        require(tokenIds.length != 0, "length error");

        require(nftAddress != address(0), "nft error");
        IERC721 nft = IERC721(nftAddress);

        uint256 tokenId;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            bool exist = false;
            for (
                uint256 x = 0;
                x < lockNfts[msg.sender][nftAddress].length;
                x++
            ) {
                if (lockNfts[msg.sender][nftAddress][x] == tokenId) {
                    lockNfts[msg.sender][nftAddress][x] = lockNfts[msg.sender][
                        nftAddress
                    ][lockNfts[msg.sender][nftAddress].length - 1];
                    lockNfts[msg.sender][nftAddress].pop();
                    exist = true;
                    break;
                }
            }
            require(exist, "tokenId not exist");
            nft.safeTransferFrom(address(this), msg.sender, tokenId);
        }

        emit TransferNFT(msg.sender, nftAddress, tokenIds);
    }

    function getLockNfts(
        address user,
        address nftAddress
    ) public view returns (uint256[] memory) {
        return lockNfts[user][nftAddress];
    }

    function getLockTokens(
        address user,
        address tokenAddress
    ) public view returns (uint256) {
        return lockTokens[user][tokenAddress];
    }

    function rescueEth() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "balance is 0");
        payable(msg.sender).transfer(balance);
    }

    function rescueToken(address address_, uint256 amount) public onlyOwner {
        IERC20(address_).transfer(msg.sender, amount);
    }

    function rescueNFT(address address_, uint256 tokenId) public onlyOwner {
        IERC721(address_).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }

    function addOperator(address user) public onlyOwner {
        operators[user] = true;
    }

    function removeOperator(address user) public onlyOwner {
        operators[user] = false;
    }

    function checkSignature(
        bytes memory signature,
        address user,
        uint256 nonce,
        uint256 expired,
        uint256 amount,
        uint256 value
    ) public view returns (bool) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                address(this),
                user,
                nonce,
                expired,
                amount,
                value,
                block.chainid
            )
        );
        return messageHash.recover(signature) == signerAddress;
    }

    function setSigner(address _signer) external onlyOwner {
        signerAddress = _signer;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
