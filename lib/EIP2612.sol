// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./IEIP2612.sol";
import "./EIP712Domain.sol";
import "./IERC20Internal.sol";

abstract contract EIP2612 is IEIP2612, IERC20Internal, EIP712Domain 
{
    mapping (address => uint256) public override nonces;

    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function permit(
        address owner, 
        address spender, 
        uint256 value, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
        ) public virtual override {
        require(deadline >= block.timestamp, "ERC20Permit: expired deadline");

        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                '\\x19',
                '\\x01',
                DOMAIN_SEPARATOR,
                hashStruct
            )
        );
        

        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0),
            "ERC20Permit: signer cant be address 0"
        );
        require(
            signer == owner,
            "ERC20Permit: signer must be the owner"
        );
        _approve(owner, spender, value);
    }
}
