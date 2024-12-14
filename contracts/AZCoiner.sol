// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract AZCoiner is ERC20Capped {
    address public treasury;

    modifier onlyTreasury() {
        require(msg.sender == treasury, "Only treasury");
        _;
    }

    constructor(
        address _treasury
    ) ERC20("AZCoiner", "AZC") ERC20Capped(5_000_000_000 * 10 ** 18) {
        treasury = _treasury;
    }

    /*
     * @dev Mint AZCoiner
     * @param recipient The address to mint to, only treasury can mint
     * @param amount The amount of AZCoiner to mint
     */
    function mint(address recipient, uint256 amount) public onlyTreasury {
        _mint(recipient, amount);
    }
}
