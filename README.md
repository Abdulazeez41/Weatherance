## Weatherance 👨🏻‍🌾 - A Decentralized Insurance aplication using Chainlink PriceFeed for payment settlement and deployed on polygon network.

This is the official repository for Moralis x Filecoin "1, 2, Web3" Hackathon 2022

## Project Overview

Consider a situation: you're a farmer 🧑‍🌾 and need to protect your crops from draught. In developed countries, you have sophisticated insurance industry, and after you send a claim, experts from your insurance company come and actually check the damage to decide on the money you'll receive.

However, farmers living in developing countries often times don't have access to that level of insurance or traditional banking. You'd like to provide them with an accessible insurance product and decide on settlements automatically to save costs.

So Weathrance is a product where farmers can buy insurance starting from 0.1 ETH (Ether, native cryptocurrency of Ethereum and second market cap after Bitcoin), about $2500 in early February 2022. So with the help of Chainlink PriceFeed integrated in the smart contract farmer's can buy insurance at the exact price rate of US Dollar in relation to Ethereum price. The smart contract as a publicly available code which has no small letters or human meddling receives temperature updates from some external provider, say maximum daily temperature every day. If the last five temperatures were hotter than some defined threshold value, contract will pay the settlement automatically.

Granted it's a contrived example and real insurance companies don't work this way, but it's a great way to discover smart contracts and how to interact with them!


## Chainlink Integration

- PriceFeed

## Advantages

- High-quality data sources that avoid manipulation from centalized entities
- Full transparency through blockchain immutability
- A well-maintained, accessible, and shared data resource
- Blockchain-agnostic to support smart contracts everywhere

## Contract Address and Website link

The Contract Address can be found [here](https://mumbai.polygonscan.com/address/0x2576935B200C69626dD99fc1B74B76472cF9FDd9#code)
Here's also a link to view the website on [vercel](https://weatherance-two.vercel.app/)
