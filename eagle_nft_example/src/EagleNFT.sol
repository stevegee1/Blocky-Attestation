// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {TAParserLib, BytesLib} from "@TAParserLib/TAParserLib.sol";
import {console} from "forge-std/Script.sol";

contract EagleNFT is ERC721URIStorage, Ownable {
    //Error
    error EagleNFT_NeedMoreEthSent();
    error EagleNFT_TransferFailed();
    error EagleNFT_randomValueOutOfBound();

    // Types
    enum Species {
        HARPY,
        MARTIAL,
        BALD
    }

    // NFT Variables
    uint256 private immutable i_mintFee;
    uint256 private s_tokenCounter;
    string[3] internal s_nftTokenURIs;
    bool private s_initialized;
    uint8 s_randomValue;

    // Events
    event NFTMinted(
        uint256 indexed tokenId,
        Species indexed specie,
        address indexed minter
    );
    event AttestedFunctionCallOutput(string output);

    constructor(
        uint256 mintFee,
        string[3] memory nftURIs
    ) ERC721("Eagle", "EAG") Ownable(msg.sender) {
        i_mintFee = mintFee;
        s_nftTokenURIs = nftURIs;
        s_tokenCounter = 0;
    }

    function labeledLog(
        string memory label, // UTF-8 encoded text
        bytes memory data
    ) public pure {
        console.log("\t%s: %s", label, string(data));
    }

    function requestNFT(
        bytes calldata applicationPublicKey,
        bytes calldata transitiveAttestation
    ) public payable returns (bool success) {
        if (msg.value < i_mintFee) {
            revert EagleNFT_NeedMoreEthSent();
        }

        TAParserLib.FnCallClaims memory claims;

        address applicationPublicKeyAsAddress = TAParserLib.publicKeyToAddress(
            applicationPublicKey
        );

        claims = TAParserLib.verifyTransitivelyAttestedFnCall(
            applicationPublicKeyAsAddress,
            transitiveAttestation
        );
        console.log("Verified attest-fn-call claims:");
        labeledLog("Function", claims.Function);
        labeledLog("Hash of code", claims.HashOfCode);
        labeledLog("Hash of input", claims.HashOfInput);
        labeledLog("Hash of secrets", claims.HashOfSecrets);
        labeledLog("Output,", claims.Output);

        bytes memory jsonBytes = bytes(claims.Output);
        for (uint i = 0; i < jsonBytes.length; i++) {
            if (
                jsonBytes[i] == '"' &&
                jsonBytes[i + 1] == "V" &&
                jsonBytes[i + 2] == "a" &&
                jsonBytes[i + 3] == "l" &&
                jsonBytes[i + 4] == "u" &&
                jsonBytes[i + 5] == "e"
            ) {
                s_randomValue = uint8(jsonBytes[i + 8]) - 48;
            }
        }
        if (s_randomValue >= 3) {
            revert EagleNFT_randomValueOutOfBound();
        }
        uint256 newItemId = s_tokenCounter;
        Species specie = Species(s_randomValue);
        s_tokenCounter = s_tokenCounter + 1;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, s_nftTokenURIs[s_randomValue]);
        emit NFTMinted(newItemId, specie, msg.sender);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert EagleNFT_TransferFailed();
        }
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getTokenURIs(uint256 index) public view returns (string memory) {
        return s_nftTokenURIs[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
