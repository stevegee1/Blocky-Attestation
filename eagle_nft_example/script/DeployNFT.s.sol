// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {EagleNFT} from "../src/EagleEye.sol";

contract DeployNFT is Script {
    function run() external returns (EagleNFT) {
        uint256 mintFee = 10000;
        string[3] memory nftURIs = [
            "https://bafybeigg3mcvp2k7qyvuj5urcd2ktfc75mhlnprtmeziyh7i2qnlmtse3m.ipfs.dweb.link?filename=Harpy.jpeg",
            "https://bafybeig5bw6badnkmqgjtuulkpq2ww2afdazz4qkrq3hc7uwohpa6tapju.ipfs.dweb.link?filename=martial.jpeg",
            "https://bafybeifhxkisg5xgpjr2pp5wyc7d6bauxqrnuv6fzezhcbho7dpzlxqknu.ipfs.dweb.link?filename=bald.jpeg"
        ];

        vm.startBroadcast();
        EagleNFT Eaglenft = new EagleNFT(mintFee, nftURIs);
        vm.stopBroadcast();
        return Eaglenft;
    }
}
