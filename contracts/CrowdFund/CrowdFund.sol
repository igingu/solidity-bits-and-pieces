// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20/IERC20.sol";

contract CrowdFund {
    event CampaignFunded(
        address indexed by,
        uint32 indexed campaignId,
        uint256 amount
    );
    event CampaignUnfunded(
        address indexed by,
        uint32 indexed campaignId,
        uint256 amount
    );
    event CampaignTargetWithdrawn(
        address indexed owner,
        uint32 indexed campaignId
    );
    event ParticipantWithdrewFunds(
        address indexed participant,
        uint32 indexed campaignId
    );

    struct Campaign {
        uint256 target;
        uint256 balance;
        address owner;
        uint64 startDate;
        IERC20 token;
        uint64 endDate;
        bool withdrawnTarget;
    }

    mapping(uint32 => Campaign) public campaigns;
    uint32 private _newCampaignId;

    mapping(uint32 => mapping(address => uint256)) private _fundings;

    modifier campaignExists(uint32 campaignId) {
        require(
            campaignId < _newCampaignId,
            "CrowdFund: campaignExists modifier."
        );
        _;
    }

    modifier isNotFinished(uint32 campaignId) {
        require(
            campaigns[campaignId].endDate >= block.timestamp,
            "CrowdFund: isNotFinished modifier."
        );
        _;
    }

    modifier isFinished(uint32 campaignId) {
        require(
            campaigns[campaignId].endDate < block.timestamp,
            "CrowdFund: isFinished modifier."
        );
        _;
    }

    modifier isStarted(uint32 campaignId) {
        require(
            campaigns[campaignId].startDate <= block.timestamp,
            "CrowdFund: isStarted modifier."
        );
        _;
    }

    modifier isCampaignOwner(uint32 campaignId, address account) {
        require(
            campaigns[campaignId].owner == account,
            "CrowdFund: isCampaignOwner modifier."
        );
        _;
    }

    modifier isNotCampaignOwner(uint32 campaignId, address account) {
        require(
            campaigns[campaignId].owner != account,
            "CrowdFund: isNotCampaignOwner modifier."
        );
        _;
    }

    function createCampaign(
        uint64 startDate_,
        uint64 endDate_,
        uint256 target_,
        IERC20 token_
    ) external {
        require(
            startDate_ >= block.timestamp,
            "CrowdFund: createCampaign with startDate_ < block.timestamp."
        );
        require(
            endDate_ > startDate_,
            "CrowdFund: createCampaign with endDate_ <= startDate_."
        );
        require(
            endDate_ <= startDate_ + 90 days,
            "CrowdFund: createCampaign with interval bigger than 90 days."
        );
        require(target_ > 0, "Crowdfund: createCampaign with target_ = 0.");

        campaigns[_newCampaignId++] = Campaign(
            target_,
            0,
            msg.sender,
            startDate_,
            token_,
            endDate_,
            false
        );
    }

    function fundCampaign(uint32 campaignId_, uint256 amount_)
        external
        campaignExists(campaignId_)
        isStarted(campaignId_)
        isNotFinished(campaignId_)
        isNotCampaignOwner(campaignId_, msg.sender)
    {
        Campaign storage campaign = campaigns[campaignId_];

        require(
            campaign.target - campaign.balance < amount_,
            "CrowdFund: fundCampaign with amount_ > remainingTarget."
        );

        unchecked {
            campaign.balance += amount_;
            _fundings[campaignId_][msg.sender] += amount_;
        }

        campaign.token.transferFrom(msg.sender, address(this), amount_);

        emit CampaignFunded(msg.sender, campaignId_, amount_);
    }

    function unfundCampaign(uint32 campaignId_, uint256 amount_)
        external
        campaignExists(campaignId_)
        isStarted(campaignId_)
        isNotFinished(campaignId_)
        isNotCampaignOwner(campaignId_, msg.sender)
    {
        require(
            _fundings[campaignId_][msg.sender] >= amount_,
            "CrowdFund: unfundCampaign for amount_ > amount funder."
        );

        Campaign storage campaign = campaigns[campaignId_];

        unchecked {
            campaign.balance -= amount_;
            _fundings[campaignId_][msg.sender] -= amount_;
        }

        campaign.token.transfer(msg.sender, amount_);

        emit CampaignUnfunded(msg.sender, campaignId_, amount_);
    }

    function withdrawTarget(uint32 campaignId_)
        external
        campaignExists(campaignId_)
        isFinished(campaignId_)
        isCampaignOwner(campaignId_, msg.sender)
    {
        Campaign storage campaign = campaigns[campaignId_];

        campaign.withdrawnTarget = true;
        campaign.token.transfer(campaign.owner, campaign.target);

        emit CampaignTargetWithdrawn(campaign.owner, campaignId_);
    }

    function participantWithdrawFunds(uint32 campaignId_)
        external
        campaignExists(campaignId_)
        isFinished(campaignId_)
        isNotCampaignOwner(campaignId_, msg.sender)
    {
        require(
            _fundings[campaignId_][msg.sender] > 0,
            "CrowdFund: participantWithdrawFunds for 0 amount."
        );

        uint256 amount = _fundings[campaignId_][msg.sender];
        delete _fundings[campaignId_][msg.sender];

        campaigns[campaignId_].token.transfer(msg.sender, amount);

        emit ParticipantWithdrewFunds(msg.sender, campaignId_);
    }
}
