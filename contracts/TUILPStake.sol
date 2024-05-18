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


contract TUILPStake is
    Ownable,
    IERC721Receiver,
    ReentrancyGuard,
    Pausable
{
    struct RewardSet {
        uint256 tuiPerSec;
        uint256 startTime;
    }
    using SafeMath for uint256;
    using Address for address;
    using ECDSA for bytes32;

    IERC20 public lpToken;
    mapping(address => uint256) public stakeTUILPs;
    IERC20 public tuiToken;
    mapping(address => uint256) public userRewardUpdateTime;
    mapping(address => uint256) public userClaimTime;
    mapping(address => uint256) public userUnClaimReward;
    RewardSet[] public rewardSetList;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);


    function stake(uint256 amount) external nonReentrant whenNotPaused {
        require(amount != 0, "amount error");
        require(!msg.sender.isContract(), "user error");

        updateUserClaim(msg.sender);

        lpToken.transferFrom(msg.sender, address(this), amount);
        stakeTUILPs[msg.sender] = stakeTUILPs[msg.sender] + amount;

        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant whenNotPaused {
        require(amount != 0, "amount error");
        require(!msg.sender.isContract(), "user error");
        require(amount <= stakeTUILPs[msg.sender], "balance error");
        require(amount <= lpToken.balanceOf(address(this)), "balance error");

        updateUserClaim(msg.sender);

        stakeTUILPs[msg.sender] = stakeTUILPs[msg.sender] - amount;
        lpToken.transfer(msg.sender, amount);

        emit Unstake(msg.sender, amount);
    }

    function claim() external nonReentrant whenNotPaused {
        require(!msg.sender.isContract(), "user error");
        updateUserClaim(msg.sender);
        uint256 reward = userUnClaimReward[msg.sender];

        uint256 balance = tuiToken.balanceOf(address(this));
        uint256 amount = reward;
        if (reward > balance) amount = balance;

        userUnClaimReward[msg.sender] = userUnClaimReward[msg.sender] - amount;

        tuiToken.transfer(msg.sender, amount);

        emit Claim(msg.sender, amount);
    }

    function updateUserClaim(address user) public {
        uint256 reward = getRewardAmount(user);
        userUnClaimReward[user] = reward;
        userRewardUpdateTime[user] = block.timestamp;
    }

    function setToken(address lp, address tui) external onlyOwner {
        lpToken = IERC20(lp);
        tuiToken = IERC20(tui);
    }

    function set1LPTuiRewardPerDay(uint256 perDay) external onlyOwner {
        rewardSetList.push(RewardSet(perDay / 86400, block.timestamp));
    }

    function updateTuiRewardPerDay(
        uint256 index,
        uint256 perDay
    ) external onlyOwner {
        rewardSetList[index].tuiPerSec = perDay / 86400;
    }

    function getRewardAmount(
        address user
    ) public view returns (uint256 reward) {
        uint256 userStake = stakeTUILPs[user];
        reward = userUnClaimReward[user];
        if (userStake == 0) return reward;

        if (rewardSetList.length == 0) return 0;

        uint256 userUpdateTime = userRewardUpdateTime[user];

        for (uint256 x = 0; x < rewardSetList.length; x++) {
            uint256 timeLeft = 0;
            if (x == rewardSetList.length - 1) {
                timeLeft = block.timestamp - userUpdateTime;
                reward =
                    reward +
                    userStake *
                    rewardSetList[x].tuiPerSec *
                    timeLeft;
                userUpdateTime = block.timestamp;
                break;
            }

            timeLeft = rewardSetList[x + 1].startTime - userUpdateTime;
            reward =
                reward +
                userStake *
                rewardSetList[x].tuiPerSec *
                timeLeft;

            userUpdateTime = rewardSetList[x + 1].startTime;
        }

        return reward;
    }

    function getStakeInfo(
        address user
    )
        external
        view
        returns (
            uint256 totalStaked,
            uint256 dailyBonus,
            uint256 userStake,
            uint256 expetchedReturns,
            uint256 fee,
            uint256 claimAbleAmount
        )
    {
        totalStaked = lpToken.balanceOf(address(this));
        uint256 tuiPerSec = rewardSetList[rewardSetList.length - 1].tuiPerSec;
        dailyBonus = tuiPerSec * 86400;
        userStake = stakeTUILPs[user];
        expetchedReturns = userStake * tuiPerSec;
        fee = 1000;
        claimAbleAmount = getRewardAmount(user);
    }

    // ----
    function setPause(bool v) external onlyOwner {
        if (v) super._pause();
        else super._unpause();
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

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
