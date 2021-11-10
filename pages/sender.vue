<template>
  <v-container>
    <v-card width="500">
      <v-card-text>
        <v-text-field v-model="to" label="to" required> </v-text-field>
      </v-card-text>
      <v-card-actions>
        <v-btn color="blue darken-1" text @click="send3()"> Send </v-btn>
      </v-card-actions>
    </v-card>
    <br />
    <br />
    <v-card width="500">
      <v-card-text>
        <v-text-field label="From" required> </v-text-field>
        <v-text-field label="to" required> </v-text-field>
      </v-card-text>
      <v-card-actions>
        <v-btn color="blue darken-1" text> Send </v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    to: "",
  }),
  methods: {
    async send() {
      const Web3 = require("web3");
      var web3 = new Web3("https://data-seed-prebsc-1-s1.binance.org:8545/");
      const abi = require("../static/abis/erc20MyToken.json");
      const contractAddress = "0x8937540faf3D16a2bFDbAaF017DA5F28dBB6903a";
      const contract = new web3.eth.Contract(abi, contractAddress);
      let estimateGas;
      //const PRIVATE_KEY = "your_key";
      try {
        let new_account = web3.eth.accounts.create(["DEMO"]);
        //web3.eth.accounts.wallet.add(PRIVATE_KEY);
        //const account = web3.eth.accounts.wallet[0].address;
        const tx = {
          // this could be provider.addresses[0] if it exists
          from: new_account.address,
          // target address, this could be a smart contract address
          to: contractAddress,
          // this encodes the ABI of the method and the arguements
          data: contract.methods
            .approve("0x0efa85f8ff1ac6a6610725af50b3564dd41ee1ae", 12)
            .encodeABI(),
        };
        web3.eth
          .getBalance(web3.currentProvider.selectedAddress)
          .then(console.log);
        const signPromise = web3.eth.accounts.signTransaction(
          tx,
          new_account.privateKey
        );
        signPromise
          .then((signedTx) => {
            web3.eth.estimateGas(signedTx).then(console.log);
            // raw transaction string may be available in .raw or
            // .rawTransaction depending on which signTransaction
            // function was called
            const sentTx = web3.eth.sendSignedTransaction(
              signedTx.raw || signedTx.rawTransaction
            );
            sentTx.on("receipt", (receipt) => {
              console.log(receipt);
            });
            sentTx.on("error", (err) => {
              console.log(err);
            });
          })
          .catch((err) => {
            console.log(err);
          });

        //console.log(web3.currentProvider.selectedAddress);
        //let result = await contract.methods.approve("0x0efa85f8ff1ac6a6610725af50b3564dd41ee1ae", 12).send({ from: "0x800d5633013855484b0271784bddea18f9ee162a" });
        //let result = await contract.methods.transferFrom("0x800d5633013855484b0271784bddea18f9ee162a" ,"0x0efa85f8ff1ac6a6610725af50b3564dd41ee1ae" , 12).send({ from: "0x800d5633013855484b0271784bddea18f9ee162a"  });
        //console.log(result);
      } catch (error) {
        console.log(error);
      }
    },
    async send2() {
      const Web3 = require("web3");
      var web3 = new Web3("https://bsc-dataseed1.ninicoin.io");
      const abi = require("../static/abis/erc20MyToken.json");
      const contractAddress = "0xad6d458402f60fd3bd25163575031acdce07538d";
      const contract = new web3.eth.Contract(abi, contractAddress);
      try {
        await contract.methods
          .transfer(this.to, web3.utils.toBN(12 * 10 ** 18))
          .send();
        console.log("send");
      } catch (error) {
        console.log(error);
      }
    },
    async send3() {
      const Web3 = require("web3");
      var web3 = new Web3(Web3.givenProvider);
      try {
        let accounts = web3.eth.getAccounts();
        const tx = {
          // this could be provider.addresses[0] if it exists
          from: web3.currentProvider.selectedAddress,
          // target address, this could be a smart contract address
          to: "0x0efa85f8ff1ac6a6610725af50b3564dd41ee1ae",
          // optional if you are invoking say a payable function
          value: web3.utils.toWei("0.00000002", "ether"),
          //gas for transactios
          gas: 218000,
        };
        accounts[0]
          .signTransaction(tx)
          .then((signedTx) => {
            const sentTx = web3.eth.sendSignedTransaction(
              signedTx.raw || signedTx.rawTransaction
            );
            sentTx.on("receipt", (receipt) => {
              console.log("Transactions sent and receipt: ", receipt);
            });
            sentTx.on("error", (err) => {
              console.log("Transactions sent error:", err);
            });
          })
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>

<style>
</style>