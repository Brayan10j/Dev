<template>
  <v-container>
    <v-row>
      <v-col>
        <v-card width="500">
          <v-card-title>
            <span class="text-h5">INDEX FUND</span>
          </v-card-title>
          <v-card-text>
            <v-container>
              <v-row>
                <v-col>
                  <v-text-field label="Quantity BNB" required></v-text-field>
                </v-col>
              </v-row>
            </v-container>
          </v-card-text>
          <v-card-actions class="mx-auto">
            <v-spacer></v-spacer>
            <v-btn color="green"> Buy </v-btn>
            <v-btn color="red"> Witdraw </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      <v-col>
        <v-card width="500">
          <v-card-title>
            <span class="text-h5">Info</span>
          </v-card-title>
          <v-card-text> MarketCap: {{ marketcap }} </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
const Web3 = require("web3");
const abi = require("../static/ABI");
const contractAddress = "0xAd2202B9E4b4CFb4d3505945B00be9c3Ea1dc260";
var web3 = new Web3(Web3.givenProvider);
const contract = new web3.eth.Contract(abi.default, contractAddress);
export default {
  data: () => ({
    to: "",
    marketcap: 0,
  }),
  methods: {
    async buy() {
      var userAccount = web3.currentProvider.selectedAddress;
      await contract.methods.buyTo().send({ from: userAccount, value: web3.utils.toWei(0, "ether")  });
    },
  },
};
</script>

<style>
</style>