// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./EIP712Domain.sol";
import "./IERC20Internal.sol";

abstract contract EIP3009 is IERC20Internal, EIP712Domain {
    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)");
    bytes32 public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH =  keccak256("ReceiveWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)");

    mapping(address => mapping(bytes32 => bool)) internal _authorizationStates;

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

    function authorizationState(address authorizer, bytes32 nonce)
        external
        view
        returns (bool)
    {
        return _authorizationStates[authorizer][nonce];
    }

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        _transferWithAuthorization(
            TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }
    
    function _transferWithAuthorization(
        bytes32 typeHash,
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        require(block.timestamp > validAfter, "EIP3009: authorization is not yet valid");
        require(block.timestamp < validBefore, "EIP3009: authorization is expired");
        require(
            !_authorizationStates[from][nonce],
            "EIP3009: authorization is used"
        );

        bytes memory hashStruct = abi.encode(
            typeHash,
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                '\\x19',
                '\\x01',                
                DOMAIN_SEPARATOR,
                keccak256(hashStruct)
            )
        );

        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0),
            "EIP3009: signer cant be address 0"
        );
        require(
            signer == from,
            "EIP3009: signer must be the owner"
        );

        _authorizationStates[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);
         _transfer(from, to, value);
    }
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(to == msg.sender, "EIP3009: caller must be the payee");

        _transferWithAuthorization(
            RECEIVE_WITH_AUTHORIZATION_TYPEHASH,
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

  
