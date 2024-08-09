<template>
  <div
    class="flex flex-col gap-[16px] flex-wrap mb-[16px] text-lg text-[#606266] font-semibold md:px-5"
  >
    <!-- dataset repo -->
    <div
      v-if="repoType === 'dataset'"
      class="w-full flex flex-wrap gap-2 items-center md:w-full md:mb-1"
    >
      <SvgIcon
        name="repoheader_dataset"
        width="16"
        height="16"
      />
      <span class="text-[#A8ABB2] text-[18px] font-medium"
        >Dataset:</span
      >
      <el-avatar
        :size="24"
        :src="avatar"
        class="flex-shrink-0"
      ></el-avatar>
      <span class="max-w-full break-words text-[#344053] font-medium">{{
        nickname.trim() === '' ? name : nickname
      }}</span>
      <div
        class="border border-[#DCDFE6] px-3 py-[2px] text-center text-xs text-[#606266] font-medium rounded"
      >
        {{ repoDetailStore.isPrivate ? $t('all.private') : $t('all.public') }}
      </div>
      <div
        class="flex cursor-pointer gap-[4px] border border-[#DCDFE6] pl-3 pr-1 py-[2px] text-center text-xs text-[#606266] font-medium rounded hover:bg-gray-50 active:ring-4 active:ring-gray-400 active:ring-opacity-25 active:bg-white"
        :class="userLiked === true ? 'text-gray-400 border-gray-200' : ''"
        @click="clickLike"
      >
        {{ userLiked === false ? $t('shared.likes') : $t('shared.hasLikes') }}
        <div class="min-h-[16px] min-w-[16px] bg-gray-100 px-1">
          {{ likesNumberDisplayName }}
        </div>
      </div>
    </div>

    <!-- endpoint -->
    <div
      v-else-if="repoType === 'endpoint'"
      class="flex flex-wrap w-full gap-2 items-center"
    >
      <el-avatar
        :size="24"
        :src="avatar"
        class="flex-shrink-0"
      ></el-avatar>
      <span class="max-w-full break-words text-[#344053] font-medium">{{
        nickname.trim() === '' ? name : nickname
      }}</span>
      <div
        class="border border-[#DCDFE6] px-3 py-[2px] text-center text-xs text-[#606266] font-medium rounded"
      >
        {{ repoDetailStore.isPrivate ? $t('all.private') : $t('all.public') }}
      </div>
      <AppStatus
        v-if="appStatus"
        :appStatus="appStatus"
        :spaceResource="spaceResource"
      />
    </div>

    <!-- finetune -->
    <div
      v-else-if="repoType === 'finetune'"
      class="flex flex-wrap w-full gap-2 items-center"
    >
      <SvgIcon
        name="model_finetune_create"
        width="16"
        height="16"
        class="flex-shrink-0"
      />
      <span class="max-w-full break-words text-[#344053] font-medium">{{
        nickname.trim() === '' ? name : nickname
      }}</span>
      <AppStatus
        v-if="appStatus"
        :appStatus="appStatus"
        :spaceResource="spaceResource"
      />
    </div>

    <!-- other repo -->
    <div
      v-else
      class="flex flex-wrap w-full gap-2 items-center"
    >
      <el-avatar
        :size="24"
        :src="avatar"
        class="flex-shrink-0"
      ></el-avatar>
      <span class="max-w-full break-words text-[#344053] font-medium">{{
        nickname.trim() === '' ? name : nickname
      }}</span>
      <div
        class="border border-[#DCDFE6] px-3 py-[2px] text-center text-xs text-[#606266] font-medium rounded"
      >
        {{ repoDetailStore.isPrivate ? $t('all.private') : $t('all.public') }}
      </div>
      <div
        class="flex cursor-pointer gap-[4px] border border-[#DCDFE6] pl-3 pr-1 py-[2px] text-center text-xs text-[#606266] font-medium rounded hover:bg-gray-50 active:ring-4 active:ring-gray-400 active:ring-opacity-25 active:bg-white"
        :class="userLiked === true ? 'text-gray-400 border-gray-200' : ''"
        @click="clickLike"
      >
        {{ userLiked === false ? $t('shared.likes') : $t('shared.hasLikes') }}
        <div class="min-h-[16px] min-w-[16px] bg-gray-100 px-1">
          {{ likesNumberDisplayName }}
        </div>
      </div>
      <AppStatus
        v-if="appStatus"
        :appStatus="appStatus"
        :spaceResource="spaceResource"
      />
      <p
        v-if="canWrite"
        class="cursor-pointer"
        @click="showSpaceLogs"
      >
        <SvgIcon
          name="instance_logs"
          width="16"
          height="16"
        />
      </p>
    </div>

    <div
      class="flex gap-1 items-center"
      v-if="repoType !== 'finetune'"
    >
      <a
        class="md:ml-0 hover:text-[#223B99] text-[#667084] font-normal"
        :href="ownerUrl"
      >
        {{ path?.split('/')[0] }}
      </a>
      <div>/</div>
      <a
        class="max-w-full break-words hover:text-[#223B99] text-[#344053] font-normal"
        href="#"
      >
        {{ repoType === 'endpoint' ? name : path?.split('/')[1] }}
      </a>
      <div
        class="cursor-pointer"
        @click="copyName"
      >
        <SvgIcon
          name="copy"
          width="16"
          height="16"
        />
      </div>
    </div>
    <div
      v-else
      class="flex gap-[8px] items-center"
    >
      <SvgIcon
        name="finetune_name_icon"
        width="16"
        height="16"
        class="flex-shrink-0"
      />
      <span class="md:ml-0 text-[#344054] font-normal hover:text-[#344054]">
        {{ path }}
      </span>
      <SvgIcon
        name="finetune_cpu_icon"
        width="16"
        height="16"
        class="flex-shrink-0 ml-6 md:ml-0"
      />
      <span class="text-[#344054] font-normal">{{ resourceName }}</span>
    </div>
    <div
      v-if="repoType === 'model' && baseModel"
      class="flex items-center text-[#344054] text-base font-normal"
    >
      {{ $t('all.baseModel') }}:
      <div @click="redirectBaseModel" class="cursor-pointer text-[#475467] hover:text-[#344054] focus:text-[#475467] ml-[8px]">
        {{ baseModel }}
      </div>
    </div>
  </div>
  <div class="leading-[24px] pb-[16px] text-[#344054] md:px-5">{{ desc }}</div>

  <!-- repo tags -->
  <header-tags
    v-if="repoType === 'model' || repoType === 'dataset'"
    :tags="tags"
    :prefix="`${repoType}s/`"
  />
</template>

<script setup>
  import HeaderTags from '../shared/HeaderTags.vue'
  import AppStatus from '../application_spaces/AppStatus.vue'
  import { copyToClipboard } from '../../packs/clipboard'
  import useRepoDetailStore from '../../stores/RepoDetailStore'
  import { ref, inject, computed, watch } from 'vue'
  import jwtFetch from '../../packs/jwtFetch'
  import { ElMessage } from 'element-plus'

  const repoDetailStore = useRepoDetailStore()

  const emit = defineEmits(['toggleSpaceLogsDrawer'])

  const props = defineProps({
    avatar: String,
    name: String,
    nickname: { type: String, default: '' },
    desc: String,
    path: String,
    license: String,
    tags: Object,
    ownerUrl: String,
    repoType: String,
    appStatus: String,
    spaceResource: String,
    canWrite: Boolean,
    repoId: Number,
    totalLikes: {
      type: Number,
      default: 0
    },
    hasLike: Boolean,
    resourceName: String,
    baseModel: String
  })

  const userLiked = ref(props.hasLike)
  const likesNumber = ref(props.totalLikes)
  const csghubServer = inject('csghubServer')

  watch(
    () => props.hasLike,
    (newVal) => {
      userLiked.value = newVal
    }
  )

  watch(
    () => props.totalLikes,
    (newVal) => {
      likesNumber.value = newVal
    }
  )

  const copyName = () => {
    copyToClipboard(props.path)
  }

  const showSpaceLogs = () => {
    emit('toggleSpaceLogsDrawer')
  }

  const likesNumberDisplayName = computed(() => {
    if (likesNumber.value > 9999) {
      return '1w+'
    } else if (likesNumber.value > 999) {
      return '1k+'
    } else {
      return likesNumber.value.toString()
    }
  })

  const likeUrl = computed(() => {
    if(props.repoType === 'collections'){
      return `${csghubServer}/api/v1/user/${props.name}/likes/collections/${props.repoId}`
    }else{
      return `${csghubServer}/api/v1/user/${props.name}/likes/${props.repoId}`
    }
  })

  const redirectBaseModel = () => {
    window.location.href = `/models/${props.baseModel}`
  }

  const clickLike = () => {
    userLiked.value === true ? removeLike() : addLike()
  }

  const addLike = async () => {
    const options = { method: 'PUT' }
    const response = await jwtFetch(
      likeUrl.value,
      options,
      true
    )
    if (!response.ok) {
      response.json().then((data) => {
        ElMessage({
          type: 'warning',
          message: data
        })
      })
    } else {
      userLiked.value = true
      likesNumber.value += 1
    }
  }

  const removeLike = async () => {
    const options = { method: 'DELETE' }
    const response = await jwtFetch(
      likeUrl.value,
      options
    )
    if (!response.ok) {
      response.json().then((data) => {
        ElMessage({
          type: 'warning',
          message: data
        })
      })
    } else {
      userLiked.value = false
      likesNumber.value -= 1
    }
  }
</script>
