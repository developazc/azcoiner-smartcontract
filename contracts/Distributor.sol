// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./interfaces/ITreasury.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VestingWalletBase} from "./base/VestingWalletBase.sol";

contract Distributor {
    uint256 public tge;

    address public owner;

    IERC20 public vestToken;

    ITreasury public treasury;

    address public preSeedVestingWallet;

    address public privateSaleVestingWallet;

    address public communityVestingWallet;

    address public ecosystemVestingWallet;

    address public treasuryVestingWallet;

    address public marketingVestingWallet;

    address public teamVestingWallet;

    address public advisorVestingWallet;

    modifier onlyOwner() {
        require(msg.sender == owner, "Distributor: caller is not the owner");
        _;
    }

    constructor(uint256 _tge, address _vestToken, address _treasury) {
        owner = msg.sender;
        tge = _tge;
        vestToken = IERC20(_vestToken);
        treasury = ITreasury(_treasury);
    }

    function distribute() public virtual onlyOwner {
        require(tge > 0, "Distributor: tge is not set");
        require(
            address(vestToken) != address(0),
            "Distributor: vestToken is not set"
        );

        // Pre-seed vesting wallet
        VestingWalletBase _preSeedVestingWallet = new VestingWalletBase(
            "Pre-seed vesting wallet",
            0x045c88f4B3B0CBAb241907892fafFaD5cBB443da,
            tge,
            30 days * 6, // 6 months
            0,
            30 days * 36, // 36 months
            250_000_000 * 10 ** 18,
            address(vestToken)
        );

        preSeedVestingWallet = address(_preSeedVestingWallet);
        treasury.mintToken(preSeedVestingWallet, 250_000_000 * 10 ** 18);

        // Private sale vesting wallet
        VestingWalletBase _privateSaleVestingWallet = new VestingWalletBase(
            "Private sale vesting wallet",
            0xA1b68BE5A48a9dE12a7df3487d9C78372fe0f78b,
            tge,
            30 days * 6, // 6 months
            17_500_000 * 10 ** 18,
            30 days * 24, // 24 months
            350_000_000 * 10 ** 18,
            address(vestToken)
        );

        privateSaleVestingWallet = address(_privateSaleVestingWallet);
        treasury.mintToken(privateSaleVestingWallet, 350_000_000 * 10 ** 18);

        // Community vesting wallet
        VestingWalletBase _communityVestingWallet = new VestingWalletBase(
            "Community vesting wallet",
            0xcaBF6073A040175A5a73b5E23D984a13d0ebFCDE,
            tge,
            30 days * 6, // 6 months
            382_500_000 * 10 ** 18,
            30 days * 240, // 240 months
            2_550_000_000 * 10 ** 18,
            address(vestToken)
        );

        communityVestingWallet = address(_communityVestingWallet);
        treasury.mintToken(communityVestingWallet, 2_550_000_000 * 10 ** 18);

        // Ecosystem vesting wallet
        VestingWalletBase _ecosystemVestingWallet = new VestingWalletBase(
            "Ecosystem vesting wallet",
            0x0536cEF6d252c33a328bD1b6F2375368df7362c2,
            tge,
            30 days * 6, // 6 months
            0,
            30 days * 24, // 24 months
            550_000_000 * 10 ** 18,
            address(vestToken)
        );

        ecosystemVestingWallet = address(_ecosystemVestingWallet);
        treasury.mintToken(ecosystemVestingWallet, 550_000_000 * 10 ** 18);

        // Treasury vesting wallet
        VestingWalletBase _treasuryVestingWallet = new VestingWalletBase(
            "Treasury vesting wallet",
            0xd72d3Ca886D41c0457c871219ba0dD21a7D84045,
            tge,
            30 days * 12, // 12 months
            0,
            30 days * 60, // 60 months
            150_000_000 * 10 ** 18,
            address(vestToken)
        );

        treasuryVestingWallet = address(_treasuryVestingWallet);
        treasury.mintToken(treasuryVestingWallet, 150_000_000 * 10 ** 18);

        // Marketing vesting wallet
        VestingWalletBase _marketingVestingWallet = new VestingWalletBase(
            "Marketing vesting wallet",
            0xf1c5ddCbcc1A87135dA9892719cF0D5b8dbe62c3,
            tge,
            0, // 0 months
            0,
            30 days * 36, // 36 months
            600_000_000 * 10 ** 18,
            address(vestToken)
        );

        marketingVestingWallet = address(_marketingVestingWallet);
        treasury.mintToken(marketingVestingWallet, 600_000_000 * 10 ** 18);

        // Team vesting wallet
        VestingWalletBase _teamVestingWallet = new VestingWalletBase(
            "Team vesting wallet",
            0xD08af200874acD8c801A7F21885A04873A50E65c,
            tge,
            30 days * 12, // 12 months
            0,
            30 days * 60, // 60 months
            250_000_000 * 10 ** 18,
            address(vestToken)
        );

        teamVestingWallet = address(_teamVestingWallet);
        treasury.mintToken(teamVestingWallet, 250_000_000 * 10 ** 18);

        // Advisor vesting wallet
        VestingWalletBase _advisorVestingWallet = new VestingWalletBase(
            "Advisor vesting wallet",
            0xc366Df1E412782Cca71c280B21A24349f619981F,
            tge,
            30 days * 12, // 12 months
            0,
            30 days * 24, // 24 months
            50_000_000 * 10 ** 18,
            address(vestToken)
        );

        advisorVestingWallet = address(_advisorVestingWallet);
        treasury.mintToken(advisorVestingWallet, 50_000_000 * 10 ** 18);
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setTge(uint256 _tge) public onlyOwner {
        tge = _tge;
    }

    function setVestToken(address _vestToken) public onlyOwner {
        vestToken = IERC20(_vestToken);
    }

    function setTreasury(ITreasury _treasury) public onlyOwner {
        treasury = _treasury;
    }
}
