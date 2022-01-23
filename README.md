# Stock Certificate NFT System (SCS)
This blockchain project is a platform that allow companies/users to generate their stock certificate NFTs.  
The functions include:
* Register a new company
* Launch a mint/split vote
* Sign the vote
* Issue NFT
* Transfer NFT
* Burn NFT
* Query company information

The contract was deployed to Ethereum testnet, and the stock certificate NFT will be on opensea testnet. 

## Links
* SCS website
  * https://elvish7.github.io/blockchain-scs-nft/scs-platform/index.html
* Contract
  * https://rinkeby.etherscan.io/address/0xd7C0ed665A348180BdBE1f34FA964E247B113067#code

## Usage
### Flow
To mint a stock certificate NFT:  
Register your company :arrow_right: Launch a mint vote :arrow_right: Get multi-signature (all the founders) :arrow_right: Issue (automatically) :arrow_right: Done!

### Registration
Input your company name, founding date, the amount of share and all the founders' keys to register. You can find your company's information by SCN Lookup after you finish the registration.  
<img src="https://user-images.githubusercontent.com/43258839/150679748-804db6c8-1627-4e74-b746-c37f9370f226.png" width="280" height="250" />

### Launch vote
Before minting or spliting the stock certificate, the company should get the agreement from the board of directors. Therefore, you need to lauch a mint/split vote and each of the founders will have to sign it if they're agree with this action. After all the founders vote/sign it, the system will issue or split the stock certificate NFT automatically.  
#### To Mint NFT
Input your company name, the NFT owner (receiver) and the amount. You will then get your NFT token ID. This step is to launch a vote, the system will only issue the NFT after all the founders sign.   
<img src="https://user-images.githubusercontent.com/43258839/150680329-ac15e040-02a3-400d-ba0d-e309e839c291.png" width="280" height="240" />

#### To Split NFT
Input your NFT token ID and other info, the system will split the shares by the input amount and send them to 2 different accounts (also requires voting).  
<img src="https://user-images.githubusercontent.com/43258839/150686974-2f474efe-39ed-4dbb-a236-b0259efa785c.png" width="280" height="230" />

### Sign
Sign/Vote by your metamask.  
<img src="https://user-images.githubusercontent.com/43258839/150680564-f442c923-9c11-4745-bb1a-442e8c10175f.png" width="280" height="180" />

### Other functions
We also provide other functions such as burn NFT and lookup company information.  
