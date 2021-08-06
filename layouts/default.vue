<template>
  <v-app dark>
    <v-navigation-drawer
      v-model="drawer"
      :mini-variant="miniVariant"
      :clipped="clipped"
      fixed
      app
    >
      <v-list>
        <v-list-item
          v-for="(item, i) in items"
          :key="i"
          :to="item.to"
          router
          exact
        >
          <v-list-item-action>
            <v-icon>{{ item.icon }}</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title v-text="item.title" />
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
    <v-app-bar :clipped-left="clipped" fixed app>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />
      <v-btn icon @click.stop="miniVariant = !miniVariant">
        <v-icon>mdi-{{ `chevron-${miniVariant ? "right" : "left"}` }}</v-icon>
      </v-btn>
      <v-btn icon @click.stop="clipped = !clipped">
        <v-icon>mdi-application</v-icon>
      </v-btn>
      <v-btn icon @click.stop="fixed = !fixed">
        <v-icon>mdi-minus</v-icon>
      </v-btn>
      <v-toolbar-title v-text="title" />
      <v-spacer />
      <v-menu bottom left>
        <template v-slot:activator="{ on, attrs }">
          <div v-show="!loged" color="blue">
            <v-btn color="blue" @click="loginMetaMask">
              <v-icon>mdi-wallet</v-icon>
              Connect
            </v-btn>
          </div>

          <div  v-show="loged" v-bind="attrs" v-on="on">
            {{ clientAdress }}
            <v-avatar>
              <v-icon> mdi-account-circle </v-icon>
            </v-avatar>
          </div>
        </template>

        <v-list>
          <v-list-item>
            <v-list-item-title>LogOut</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-app-bar>
    <v-main>
      <v-container>
        <nuxt />
      </v-container>
    </v-main>

    <v-footer :absolute="!fixed" app>
      <span>&copy; {{ new Date().getFullYear() }}</span>
    </v-footer>
  </v-app>
</template>

<script>
export default {
  data() {
    return {
      clipped: false,
      clientAdress: "",
      drawer: false,
      fixed: false,
      items: [
        {
          icon: "mdi-map",
          title: "Mapbox",
          to: "/",
        },
        {
          icon: "mdi-store",
          title: "Marketplace NFTs",
          to: "/inspire",
        },
        {
          icon: "mdi-file",
          title: "File hash",
          to: "/fileHash",
        },
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: "SERVER",
      loged: false,
    };
  },
  methods: {
    async loginMetaMask() {
      try {
        if (typeof window.ethereum === "undefined")
          alert("MetaMask not installed  :(");
        await window.ethereum.request({ method: "eth_requestAccounts" });
        let dir = window.ethereum.selectedAddress;
        this.clientAdress = dir.slice(0, 5) + ".." + dir.slice(-3);
        this.loged = true;
      } catch (error) {
        console.log(error);
        this.loged = false;
      }
    },
    logOut() {
      // quitar de metamask
      this.loged = false;
    },
    loginBinance() {
      window.BinanceChain.request({ method: "eth_accounts" });
    },
  },
  mounted() {
    let dir;
    let ctx = this;
    if (window.ethereum.selectedAddress == undefined) {
      this.loged = false;
    } else {
      dir = window.ethereum.selectedAddress;
      this.clientAdress = dir.slice(0, 5) + ".." + dir.slice(-3);
      this.loged = true;
    }
    window.ethereum.on("accountsChanged", function (accounts) {
      if (accounts[0] == undefined) {
        ctx.loged = false;
      } else {
        dir = accounts[0];
        ctx.clientAdress = dir.slice(0, 5) + ".." + dir.slice(-3);
        ctx.loged = true;
      }
    });
  },
};
</script>
