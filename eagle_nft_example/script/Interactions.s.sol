// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console, stdJson} from "forge-std/Script.sol";
import {EagleNFT} from "../src/EagleNFT.sol";
import {Base64} from "../lib/solady/src/utils/Base64.sol";

contract mintNFT is Script {
    function run() external {
        address mostRecentlyDeployedContract = address(
            0xfD04fdA6e1AFbDAD93fe3C8B2a36d5103998b8D9
        );
        mintNFTOnContract(mostRecentlyDeployedContract);
    }

    function mintNFTOnContract(address EagleNFTAddress) public {
        bytes memory rawByte = vm.readFileBinary("./random/tmp/output.bytes");
        bytes memory rawBytes = vm.readFileBinary("./random/tmp/outputs.bytes");

        vm.startBroadcast();

        EagleNFT(EagleNFTAddress).requestNFT{value: 100000}(rawByte, rawBytes);
        vm.stopBroadcast();
    }
}
