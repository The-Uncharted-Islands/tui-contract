//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TUIStake is Ownable, IERC721Receiver {
    using SafeMath for uint256;

    IERC20 public token;
    IERC721 public nft;

    struct StakePool {
        uint256 poolId;
        uint256 startTime;
        uint256 endTime; // 0 is forever
        uint256 rewardPerHour;
        bool exist;
    }

    mapping(address => mapping(uint256 => uint256)) public stakers;
    mapping(address => uint256[]) public stakeNfts;
    mapping(uint256 => StakePool) public pools;

    event Stake(address indexed user, uint256 poolId, uint256 amount);
    event Unstake(address indexed user, uint256 poolId);
    event StakeNFT(address indexed user, uint256[] tokenIds);
    event UnstakeNFT(address indexed user, uint256[] tokenIds);
    event AddPool(
        uint256 poolId,
        uint256 startTime,
        uint256 endTime,
        uint256 rewardPerHour
    );
    event UpdatePool(
        uint256 poolId,
        uint256 startTime,
        uint256 endTime,
        uint256 rewardPerHour
    );

    constructor() {
    }

    function stake(uint256 poolId, uint256 amount) external {
        require(amount != 0, "amount error");
        // require pool has started and startTime less then block time
        require(
            pools[poolId].startTime < block.timestamp &&
                pools[poolId].startTime != 0,
            "start time error"
        );
        // require pool not end or pool is forever
        require(
            block.timestamp < pools[poolId].endTime ||
                pools[poolId].endTime == 0,
            "end time has arrived"
        );

        stakers[msg.sender][poolId] = stakers[msg.sender][poolId] + amount;
        token.transferFrom(msg.sender, address(this), amount);

        emit Stake(msg.sender, poolId, amount);
    }

    function unstakePools(uint256[] memory poolIds) external {
        uint256 poolId;

        for (uint256 i = 0; i < poolIds.length; i++) {
            poolId = poolIds[i];
            unstake(poolId);
        }
    }

    function unstake(uint256 poolId) public {
        uint256 amount = stakers[msg.sender][poolId];
        require(amount != 0, "amount error");
        require(amount <= token.balanceOf(address(this)), "balance error");

        require(
            block.timestamp > pools[poolId].endTime ||
                pools[poolId].endTime == 0,
            "the end time has not yet arrived"
        );

        stakers[msg.sender][poolId] = 0;
        token.transfer(msg.sender, amount);

        emit Unstake(msg.sender, poolId);
    }

    function stakeNFT(uint256[] memory tokenIds) external {
        require(tokenIds.length != 0, "length error");
        uint256 tokenId;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            stakeNfts[msg.sender].push(tokenId);
        }
        emit StakeNFT(msg.sender, tokenIds);
    }

    function unstakeNFT(uint256[] memory tokenIds) external {
        require(tokenIds.length != 0, "length error");

        require(stakeNfts[msg.sender].length != 0, "none nft in staking");

        uint256 tokenId;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            bool exist = false;
            for (uint256 x = 0; x < stakeNfts[msg.sender].length; x++) {
                if (stakeNfts[msg.sender][x] == tokenId) {
                    stakeNfts[msg.sender][x] = stakeNfts[msg.sender][
                        stakeNfts[msg.sender].length - 1
                    ];
                    stakeNfts[msg.sender].pop();
                    exist = true;
                    break;
                }
            }
            require(exist, "tokenId not exist");
            nft.safeTransferFrom(address(this), msg.sender, tokenId);
        }

        emit UnstakeNFT(msg.sender, tokenIds);
    }

    function getStakeNfts(address user) public view returns (uint256[] memory) {
        return stakeNfts[user];
    }

    function setStakePool(
        uint256 poolId,
        uint256 startTime,
        uint256 endTime,
        uint256 rewardPerHour
    ) external onlyOwner {
        if (!pools[poolId].exist) {
            // if pool not exist
            pools[poolId] = StakePool(
                poolId,
                startTime,
                endTime,
                rewardPerHour,
                true
            );

            emit AddPool(poolId, startTime, endTime, rewardPerHour);
        } else {
            // else
            pools[poolId].startTime = startTime;
            pools[poolId].endTime = endTime;
            pools[poolId].rewardPerHour = rewardPerHour;
            emit UpdatePool(poolId, startTime, endTime, rewardPerHour);
        }
    }

    function setStakeToken(address st) external onlyOwner {
        token = IERC20(st);
    }

    function setStakeNFT(address st) external onlyOwner {
        nft = IERC721(st);
    }

    function withdrawEth() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "balance is 0");
        payable(msg.sender).transfer(balance);
    }

    function withdrawToken(address address_, uint256 amount) public onlyOwner {
        IERC20(address_).transfer(msg.sender, amount);
    }

    function withdrawNFT(address address_, uint256 tokenId) public onlyOwner {
        IERC721(address_).safeTransferFrom(address(this), msg.sender, tokenId);
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
