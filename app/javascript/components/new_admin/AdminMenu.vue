<template>
  <div
    class="flex flex-col gap-[8px] w-[260px] p-[20px] border rounded-[10px] bg-[#F4F4F6]"
  >
    <RouterLink
      to="/new_admin/"
      class="underline"
    >
      {{ $t('admin.dashboard.title') }}
    </RouterLink>

    <RouterLink
      to="/new_admin/system_config"
      class="underline"
    >
      System Config
    </RouterLink>

    <RouterLink
      to="/new_admin/users"
      class="underline"
    >
      Users
    </RouterLink>

    <RouterLink
      v-if="onPremise === 'true'"
      to="/new_admin/sync"
      class="underline"
    >
      Sync Setting
    </RouterLink>

    <RouterLink
      v-if="onPremise === 'false'"
      to="/new_admin/email_sending"
      class="underline"
    >
      Email Sending
    </RouterLink>
  </div>
</template>

<script setup>
  import { ref, inject } from 'vue';

  const onPremise = inject('onPremise', ref('true'))
</script>
