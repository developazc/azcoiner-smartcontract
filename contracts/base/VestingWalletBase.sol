// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "hardhat/console.sol";

contract VestingWalletBase is Context {
    string public _NAME_;

    event EtherReleased(uint256 amount);

    event ERC20Released(address indexed token, uint256 amount);

    uint256 internal _maxRelease;

    mapping(address => uint256) private _erc20Released;

    address internal _beneficiary;

    address internal _vestToken;

    uint256 internal _startTime;

    uint256 internal _duration;

    uint256 internal _tge;

    uint256 internal _amountReleaseAfterTge;

    uint256 internal _cliff;

    bool public isClaimedAfterTge;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(
        string memory name,
        address beneficiaryAddress,
        uint256 tge,
        uint256 cliff,
        uint256 amountReleaseAfterTge,
        uint256 durationVesting,
        uint256 maxRelease,
        address vestToken
    ) {
        _NAME_ = name;
        require(
            beneficiaryAddress != address(0),
            "VestingWallet: beneficiary is zero address"
        );
        _beneficiary = beneficiaryAddress;

        require(tge > 0, "VestingWallet: tge is zero");

        _tge = tge;
        _cliff = cliff;
        _amountReleaseAfterTge = amountReleaseAfterTge;

        _duration = durationVesting;
        _startTime = tge + cliff;

        _maxRelease = maxRelease;

        _vestToken = vestToken;

        isClaimedAfterTge = false;
    }

    /**
     * @dev Getter for the beneficiary address.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Getter for the start timestamp.
     */
    function start() public view virtual returns (uint256) {
        return _startTime;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /*
     * @dev Getter for the tge
     */
    function tge() public view virtual returns (uint256) {
        return _tge;
    }

    /*
     * @dev Getter for the cliff
     */
    function cliff() public view virtual returns (uint256) {
        return _cliff;
    }

    function amountReleaseAfterTge() public view virtual returns (uint256) {
        return _amountReleaseAfterTge;
    }

    /**
     * @dev Amount of eth already released
     */
    function released() public view virtual returns (uint256) {
        return _erc20Released[_vestToken];
    }

    /**
     * @dev Amount of token already released
     */
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }

    function maxRelease() public view virtual returns (uint256) {
        return _maxRelease;
    }

    function remainingRelease() public view virtual returns (uint256) {
        return IERC20(_vestToken).balanceOf(address(this));
    }

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(address token) public view virtual returns (uint256) {
        return vestedAmount(token, uint64(now())) - released(token);
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release() public virtual {
        require(
            msg.sender == _beneficiary,
            "VestingWallet: caller is not beneficiary"
        );
        uint256 _releasable = releasable(_vestToken);
        _erc20Released[_vestToken] += _releasable;
        emit ERC20Released(_vestToken, _releasable);
        SafeERC20.safeTransfer(IERC20(_vestToken), beneficiary(), _releasable);
    }

    function claimAfterTge() public virtual {
        require(
            msg.sender == _beneficiary,
            "VestingWallet: caller is not beneficiary"
        );
        require(now() >= _tge, "VestingWallet: tge not reached");
        require(isClaimedAfterTge == false, "VestingWallet: already claimed");
        SafeERC20.safeTransfer(
            IERC20(_vestToken),
            beneficiary(),
            _amountReleaseAfterTge
        );
        isClaimedAfterTge = true;
    }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(
        address token,
        uint64 timestamp
    ) public view virtual returns (uint256) {
        return
            _vestingSchedule(
                IERC20(token).balanceOf(address(this)) + released(token),
                timestamp
            );
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(
        uint256 totalAllocation,
        uint64 timestamp
    ) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }

    function now() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
