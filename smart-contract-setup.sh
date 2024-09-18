#!/bin/bash

# Define Variables
GITHUB_REPO="https://github.com/kattyjeo/swisstronik.git"
GITHUB_USERNAME="kattyjeo"
COMMIT_MESSAGE="Add smart contract and deployment files"

# Step 1: Install Node.js if not installed
if ! command -v node &> /dev/null
then
    echo "Node.js not found, installing..."
    sudo apt update
    sudo apt install nodejs npm -y
else
    echo "Node.js is already installed."
fi

# Step 2: Set up Hardhat project
echo "Setting up Hardhat project..."
mkdir smart-contract && cd smart-contract
npm init -y
npm install --save-dev hardhat
npx hardhat --yes

# Step 3: Add simple smart contract
echo "Adding simple smart contract..."
cat <<EOF > contracts/MyFirstContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyFirstContract {
    string public message;

    constructor(string memory _message) {
        message = _message;
    }

    function updateMessage(string memory _newMessage) public {
        message = _newMessage;
    }
}
EOF

# Step 4: Modify deployment script
echo "Modifying deployment script..."
cat <<EOF > scripts/deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);

  const MyFirstContract = await ethers.getContractFactory("MyFirstContract");
  const contract = await MyFirstContract.deploy("Hello, Blockchain!");

  console.log("Contract deployed to address:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
EOF

# Step 5: Add Hardhat config for test network (Ropsten)
echo "Configuring Hardhat for Ropsten network..."
cat <<EOF > hardhat.config.js
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.0",
  networks: {
    ropsten: {
      url: \`https://eth-ropsten.alchemyapi.io/v2/YOUR_ALCHEMY_API_KEY\`,
      accounts: [\`0xYOUR_PRIVATE_KEY\`]
    }
  }
};
EOF

# Step 6: Clone GitHub repository
echo "Cloning GitHub repository..."
git clone $GITHUB_REPO
cd swisstronik

# Step 7: Copy the Hardhat project files to the repo
echo "Copying project files to GitHub repository..."
cp -r ../smart-contract/* .

# Step 8: Commit and push to GitHub
echo "Pushing code to GitHub..."
git add .
git commit -m "$COMMIT_MESSAGE"
git push origin main

echo "Process complete! Smart contract code pushed to GitHub."
