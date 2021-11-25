<template>
  <v-container fluid>
    <section>
      <div class="text-h1 mb-6 text-center">{{ marketcap.toFixed(2) }}</div>
      <div class="text-h5 mb-6 text-center">Estimate ganancies</div>
    </section>
    <br>
    <br>
    <section>
      <v-row>
        <v-col v-for="(item, i ) in coins" :key="i">
          <v-card class="mx-auto" width="120">
            <v-card-text>
              <v-img :src="item.image">

              </v-img>
              <h5>{{(item.price_change_percentage_24h.toFixed(2))}} %(24h)</h5>
            </v-card-text>
            
          </v-card>
        </v-col>
      </v-row>
    </section>
    <section>
      <v-row>
        <v-col>
          <v-card >
            <v-card-title>
              <span class="text-h5">INDEX FUND</span>
            </v-card-title>
            <v-card-text>
              <v-container>
                <v-row>
                  <v-col>
                    <v-text-field
                      v-model.number="value"
                      label="Quantity "
                      required
                      prefix="$"
                      suffix="(USD)"
                    ></v-text-field>
                  </v-col>
                </v-row>
              </v-container>
            </v-card-text>
            <v-card-actions class="mx-auto">
              <v-spacer></v-spacer>
              <v-btn color="green" @click="buy"> Deposit </v-btn>
              <v-btn color="red" @click="withdraw"> Witdraw </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
        <v-col>
          <v-card>
            <v-card-title> TOTAL LOCK VALUE </v-card-title>
            <v-card-text>
              <p>
                <span>{{ marketcap.toFixed(2) }}</span
                ><span> UST</span>
              </p>
              <v-row>
                <v-col>
                  <canvas
                    width="152"
                    height="152"
                    style="display: block; box-sizing: border-box"
                  ></canvas>
                </v-col>
                <v-col>
                  <h3>
                    <i style="background-color: rgb(75, 219, 75)"></i>
                    Total Deposit
                  </h3>
                  <p>
                    $
                    <span>{{ deposit }}</span>
                  </p>
                  <h3>
                    <i style="background-color: rgb(31, 31, 31)"></i>
                    Total Collateral
                  </h3>
                  <p>
                    $
                    <span>{{ marketcap.toFixed(2) }}</span>
                  </p>
                </v-col>
              </v-row>
              <hr />
              
                <v-card-title>TEAM RESERVE</v-card-title>
                <p>
                  <span
                    >$
                    {{
                      (tokensTeam * (marketcap / totalSupply)).toFixed(2)
                    }}</span
                  ><span> USDT</span>
                </p>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </section>
    <br />
    <br />

    <section>
      <v-card>
        <v-row>
          <v-col>
            <v-card-title> S20 Price</v-card-title>
            <v-card-text>
              {{ (marketcap / totalSupply).toFixed(2) }}<span> UST</span>
            </v-card-text>
          </v-col>
          <v-col>
            <v-card-title> Circulating Supply</v-card-title>

            <v-card-text>{{ totalSupply }}<span> (S20)</span></v-card-text>
          </v-col>
          <v-col>
            <v-card-title> S20 Market Cap</v-card-title>
            <v-card-text
              >{{ marketcap.toFixed(2) }}<span> UST</span></v-card-text
            >
          </v-col>
        </v-row>
        <v-row>
          <v-card-text>
            <v-sheet color="rgba(0, 0, 0, .12)">
              <v-sparkline
                :value="values"
                color="rgba(255, 255, 255, .7)"
                height="100"
                padding="24"
                stroke-linecap="round"
                smooth
              >
                <template v-slot:label="item"> ${{ item.value }} </template>
              </v-sparkline>
            </v-sheet>
          </v-card-text>
        </v-row>
      </v-card>
    </section>
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
    values: [423, 446, 675, 510, 590, 610, 760],
    estimate: 0,
    value: 0,
    averagePercent: 0,
    deposit: 0,
    totalSupply: 0,
    tokens: 0,
    tokensTeam: 0,
    coins: []
  }),
  methods: {
    async buy() {
      //var userAccount = web3.currentProvider.selectedAddress;
      //await contract.methods
      //.buyTo()
      //.send({ from: userAccount, value: web3.utils.toWei(0, "ether") });
      this.deposit = this.deposit + this.value;
      let tokens;
      if (this.totalSupply == 0) {
        tokens = this.value;
        this.marketcap = this.value;
      } else {
        tokens = this.value / (this.marketcap / this.totalSupply);
        this.marketcap = this.marketcap + this.value;
      }
      this.tokensTeam = this.tokensTeam + tokens * 0.13;
      this.totalSupply = this.totalSupply + tokens * 1.13;
      this.tokens = this.tokens + tokens;
      this.calculatePercent();
      this.value = 0;
    },
    async withdraw() {
      if (this.value > 0) {
        if (this.tokens >= this.value) {
          let withdrawValue = (this.value * this.marketcap) / this.totalSupply;
          if (this.marketcap >= withdrawValue) {
            // cambia en el smart contract
            this.totalSupply = this.totalSupply - this.value;
            this.tokens = this.tokens - this.value;
            this.marketcap = this.marketcap - withdrawValue;
          } else {
            alert("balance contract insuficient"); // rebundance
          }
        } else {
          alert("tokens insuficient");
        }
      } else {
        alert("value 0");
      }
      this.calculatePercent();
      this.value = 0;
    },
    async calculatePercent() {
      let { data } = await this.$axios.get(
        "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=5&page=1&sparkline=false"
      );
      this.coins = data
      let percentChange = 0;
      data.forEach((element) => {
        percentChange = percentChange + element.price_change_percentage_24h;
      });
      this.averagePercent = percentChange / data.length / (24 * 60 * 60); // segundos
    },
    async calculate() {
      await this.calculatePercent();
      setInterval(() => {
        this.marketcap = this.marketcap * this.averagePercent + this.marketcap;
        this.estimate = this.marketcap;
      }, 1000);
    },
  },
  created() {
    this.calculate();
  },
};
</script>

