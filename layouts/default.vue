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
    <v-app-bar
      :clipped-left="clipped"
      fixed
      app
    >
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />
      <v-btn
        icon
        @click.stop="miniVariant = !miniVariant"
      >
        <v-icon>mdi-{{ `chevron-${miniVariant ? 'right' : 'left'}` }}</v-icon>
      </v-btn>
      <v-btn
        icon
        @click.stop="clipped = !clipped"
      >
        <v-icon>mdi-application</v-icon>
      </v-btn>
      <v-btn
        icon
        @click.stop="fixed = !fixed"
      >
        <v-icon>mdi-minus</v-icon>
      </v-btn>
      <v-toolbar-title v-text="title" />
      <v-spacer />
      <v-btn
        icon
        @click.stop="rightDrawer = !rightDrawer"
      >
        <v-icon>mdi-menu</v-icon>
      </v-btn>
    </v-app-bar>
    <v-main>
      <v-container>
        <nuxt />
      </v-container>
    </v-main>
    <v-navigation-drawer
      v-model="rightDrawer"
      :right="right"
      temporary
      fixed
    >
      <v-list>
        <v-list-item @click.native="right = !right">
          <v-list-item-action>
            <v-icon light>
              mdi-repeat
            </v-icon>
          </v-list-item-action>
          <v-list-item-title>Switch drawer (click me)</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
    <v-footer
      :absolute="!fixed"
      app
    >
      <span>&copy; {{ new Date().getFullYear() }}</span>
    </v-footer>
    <v-dialog
      v-model="dialogLoginMetaMask"
      persistent
      max-width="400"
    >
    <v-card>
        <v-card-title class="text-h5">
          Metamask not conected !!
        </v-card-title>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            text
            @click="loginMetaMask"
          >
            Connect
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-app>

  
</template>

<script>
export default {
  data () {
    return {
      dialogLoginMetaMask: false,
      clipped: false,
      drawer: false,
      fixed: false,
      items: [
        {
          icon: 'mdi-apps',
          title: 'Mapbox',
          to: '/'
        },
        {
          icon: 'mdi-chart-bubble',
          title: 'NFT',
          to: '/inspire'
        }
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: 'SERVER'
    }
  },
  methods: {
    async loginMetaMask() {
      try {
          await window.ethereum.request({ method: "eth_requestAccounts" });
          this.dialogLoginMetaMask = !this.dialogLoginMetaMask
        } catch (error) {
          alert(error.message)
          this.dialogLoginMetaMask = true
        }
    },
    loginBinance() {
      window.BinanceChain.request({ method: "eth_accounts" });
    },
  },
  mounted(){
    if (typeof window.ethereum !== "undefined") {
      console.log("MetaMask is installed!");
    }else{
      alert("MetaMask not installed  :(")
    }   
    if (window.ethereum.selectedAddress == undefined) this.loginMetaMask()
  }
}
</script>
