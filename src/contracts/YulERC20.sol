// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// keccak256(Transfer(address,address,uint256))
bytes32 constant TRANSFER_EVENT = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
// keccak256(Approval(address,address,uint256))
bytes32 constant APPROVAL_EVENT = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

uint256 constant TOTAL_SUPPLY = 5_000_000_000e18;
address constant OWNER = 0x5e078E6b545cF88aBD5BB58d27488eF8BE0D2593;

/**
* @title YulERC20, a better version of SunToken.
* @author Anthony (fps) https://github.com/0xfps.
* @dev  YulERC20, ERC20, but entirely Yul.
*       Name: YulERC20, 0x59756c4552433230, 0x08
*       Symbol: $YERC, 0x2459455243, 0x05
*       Decimals: 18
* @notice It's a challenge to avoid one line of solidity inside functions.
*/

contract YulERC20 is IERC20 {
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowances;

    constructor() {
        assembly {
            mstore(0x00, OWNER)
            mstore(0x20, 0x00)
            sstore(keccak256(0x00, 0x40), TOTAL_SUPPLY)
        }
    }

    function name() public pure returns (string memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x28, 0x0859756c4552433230)
            return(0x00, 0x60)
        }
    }

    function symbol() public pure returns (string memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x25, 0x052459455243)
            return(0x00, 0x60)
        }
    }

    function decimals() public pure returns (uint8) {
        assembly {
            mstore(0x00, 0x12)
            return(0x00, 0x20)
        }
    }

    function totalSupply() public pure returns (uint256) {
        assembly {
            mstore(0x00, TOTAL_SUPPLY)
            return(0x00, 0x20)
        }
    }

    function balanceOf(address) public view returns (uint256) {
        assembly {
            mstore(0xa0, calldataload(0x04))
            mstore(0xc0, 0x00)
            mstore(0xe0, sload(keccak256(0xa0, 0x40)))
            return(0xe0, 0x20)
        }
    }

    function transfer(address, uint256) public returns (bool) {
        assembly {
            // Get slot for to, calldataload(4)
            // 0x11111111
            // Starts at calldataload(4)
            // 0x000000000000000000000000Ef9f1ACE83dfbB8f559Da621f4aEA72C6EB10eBf
            // Starts at calldataload(36)
            // 0x000000000000000000000000Ef9f1ACE83dfbB8f559Da621f4aEA72C6EB10eBf

            let to := calldataload(0x04)
            let amount := calldataload(0x24)

            if iszero(
                and(caller(), 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            if iszero(
                and(to, 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            mstore(0x00, to)
            mstore(0x20, 0x00)
            let toSlot := keccak256(0x00, 0x40)
            let toBalance := sload(toSlot)

            mstore(0x00, caller())
            mstore(0x20, 0x00)
            let callerSlot := keccak256(0x00, 0x40)
            let callerBalance := sload(callerSlot)

            if lt(callerBalance, amount) {
                revert(0x00, 0x00)
            }

            sstore(toSlot, add(sload(toSlot), amount))
            sstore(callerSlot, sub(sload(callerSlot), amount))

            mstore(0x00, amount)
            log3(0x00, 0x20, TRANSFER_EVENT, caller(), to)

            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    function approve(address, uint256) public returns (bool) {
        assembly {
            let spender := calldataload(0x04)
            let amount := calldataload(0x24)

            if iszero(
                and(caller(), 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            if iszero(
                and(spender, 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            mstore(0x00, caller())
            mstore(0x20, 0x01)
            let ownerSlot := keccak256(0x00, 0x40)

            mstore(0x00, spender)
            mstore(0x20, ownerSlot)
            let fullLocation := keccak256(0x00, 0x40)

            sstore(fullLocation, amount)

            mstore(0x00, amount)
            log3(0x00, 0x20, APPROVAL_EVENT, caller(), spender)

            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    function allowance(address, address) public view returns (uint256) {
        assembly {
            let owner := calldataload(0x04)
            let spender := calldataload(0x24)

            mstore(0x00, owner)
            mstore(0x20, 0x01)
            let ownerSlot := keccak256(0x00, 0x40)

            mstore(0x00, spender)
            mstore(0x20, ownerSlot)
            let fullLocation := keccak256(0x00, 0x40)

            mstore(0x00, sload(fullLocation))
            return(0x00, 0x20)
        }
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        assembly {
            let owner := calldataload(0x04)
            let to := calldataload(0x24)
            let amount := calldataload(0x44)

            let spender := caller()

            if iszero(
                and(owner, 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            if iszero(
                and(to, 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            // Get the allowance.
            mstore(0x00, owner)
            mstore(0x20, 0x01)
            let ownerSlot := keccak256(0x00, 0x40)

            mstore(0x00, spender)
            mstore(0x20, ownerSlot)
            let fullAllowanceSlot := keccak256(0x00, 0x40)
            let fullAllowance := sload(fullAllowanceSlot)

            // Get balance of owner.
            mstore(0x00, owner)
            mstore(0x20, 0x00)
            let ownerBalanceSlot := keccak256(0x00, 0x40)
            let ownerBalance := sload(ownerBalanceSlot)

            // Get balance of to.
            mstore(0x00, to)
            mstore(0x20, 0x00)
            let toBalanceSlot := keccak256(0x00, 0x40)
            let toBalance := sload(toBalanceSlot)

            if lt(fullAllowance, amount) {
                revert(0x00, 0x00)
            }

            if lt(ownerBalance, amount) {
                revert(0x00, 0x00)
            }

            sstore(fullAllowanceSlot, sub(fullAllowance, amount))
            sstore(toBalanceSlot, add(sload(toBalanceSlot), amount))
            sstore(ownerBalanceSlot, sub(sload(ownerBalanceSlot), amount))

            mstore(0x00, amount)
            log3(0x00, 0x20, TRANSFER_EVENT, owner, to)

            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    function burn(uint256) public returns (bool) {
        assembly {
            let from := caller()
            let amount := calldataload(0x04)

            if iszero(
                and(from, 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            mstore(0x00, from)
            mstore(0x20, 0x00)
            let fromSlot := keccak256(0x00, 0x40)
            let fromBalance := sload(fromSlot)

            mstore(0x00, OWNER)
            mstore(0x20, 0x00)
            let toSlot := keccak256(0x00, 0x40)
            let toBalance := sload(toSlot)

            if lt(fromBalance, amount) {
                revert(0x00, 0x00)
            }

            sstore(toSlot, add(sload(toSlot), amount))
            sstore(fromSlot, sub(sload(fromSlot), amount))

            mstore(0x00, amount)
            log3(0x00, 0x20, TRANSFER_EVENT, from, OWNER)

            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }
}