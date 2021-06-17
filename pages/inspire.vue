<template>
  <div>
    <v-file-input
      label="File single  input"
      v-model="single"
      @change="getFile"
    ></v-file-input>
    <v-img :src="objectURL" max-width="400px" aspect-ratio="2"></v-img>
    <!--
    <v-file-input
      multiple
      label="File multiple input"
      v-model="multiple"
    ></v-file-input>
    -->
    <v-btn right @click="getHashIPFS">Create NFT</v-btn>
  </div>
</template>

<script>
export default {
  components: {},
  data() {
    return {
      single: null,
      singleBuffer: null,
      multiple: null,
      objectURL: null,
    };
  },
  methods: {
    getFile(e) {
      const reader = new FileReader();
      this.objectURL = URL.createObjectURL(e);
      reader.readAsArrayBuffer(e);
      reader.onload = (e) => {
        this.singleBuffer = e.target.result;
      };
    },
    async getHashIPFS() {
      const IPFS = require("ipfs-core");
      const Web3 = require("web3");
      const abi = require("../static/ABI");
      //var ipfs = await IPFS.create();
      try {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        var web3 = new Web3(Web3.givenProvider);
        let userAccount = web3.currentProvider.selectedAddress;
        var contractAddress = "0xDCCfA64e5Be095834C79EE8a3A4F83855BfB9cB8";
        var contract = new web3.eth.Contract(abi.default, contractAddress);
        //const results = await ipfs.add(this.singleBuffer);
        await contract.methods
          .awardItem(userAccount, this.objectURL)
          .send({ from: userAccount });
        alert("NFT creado");
      } catch (error) {
        alert(error);
      }
    },
  },
};
</script>

<style>
</style>
