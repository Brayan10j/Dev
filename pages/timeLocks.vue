<template>
  <v-card>
    <v-card-title>
      <span class="text-h5">TimeLock</span>
    </v-card-title>
    <v-card-text>
      <v-container>
        <v-row>
          <v-col cols="12" sm="6" md="4">
            <v-text-field label="Token" required></v-text-field>
          </v-col>
          <v-col cols="12" sm="6" md="4">
            <v-text-field
              label="Beneficiary"
              hint="example of helper text only on focus"
            ></v-text-field>
          </v-col>
          <v-col cols="12" sm="6" md="4">
            
              <v-menu
                v-model="menu2"
                :close-on-content-click="false"
                :nudge-right="40"
                transition="scale-transition"
                offset-y
                min-width="auto"
              >
                <template v-slot:activator="{ on, attrs }">
                  <v-text-field
                    v-model="date"
                    label="Picker without buttons"
                    prepend-icon="mdi-calendar"
                    readonly
                    v-bind="attrs"
                    v-on="on"
                  ></v-text-field>
                </template>
                <v-date-picker
                  v-model="date"
                  @input="menu2 = false"
                ></v-date-picker>
              </v-menu>
            
          </v-col>
          {{date}}
        </v-row>
      </v-container>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn color="blue darken-1" @click="send()" > Save </v-btn>

    </v-card-actions>
  </v-card>
</template>

<script>
export default {
  data: () => ({
    date: new Date(Date.now() - new Date().getTimezoneOffset() * 60000)
      .toISOString()
      .substr(0, 10),

    menu2: false,
  }),
  methods:{
    send(){
      let myDate = (this.date).split("-");
      var newDate = new Date( myDate[0], myDate[1] - 1, myDate[2]);
      console.log(newDate > new Date(Date.now()));
      console.log(newDate.getTime());
    }
  }
};
</script>

<style>
</style>