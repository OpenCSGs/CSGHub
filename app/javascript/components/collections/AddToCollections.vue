<template>
  <div
    class="AddRepoToCollections absolute top-0 right-[120px] md:relative md:right-0 md:pl-5 md:pb-4 z-20"
  >
    <div
      v-if="settingsVisibility"
      @click="dialogVisible = true"
      class="flex max-w-[max-content] px-3 py-[5px] text-[14px] leading-[20px] border border-[#D0D5DD] justify-center items-center gap-[6px] rounded-lg shadow-[0px_1px_2px_0px_rgba(16,24,40,0.05)] cursor-pointer"
    >
      <SvgIcon
        name="collections"
        width="12px"
        height="12px"
      />
      {{ $t('collections.edit.addCollection') }}
    </div>
    <el-dialog
      v-model="dialogVisible"
      top="10vh"
      :style="{ borderRadius: '10px' }"
      width="450"
      class="invite_dialog"
    >
      <template #header="{ close }">
        <div class="flex justify-between">
          <div
            class="rounded-full px-[12px] py-[12px] rounded-[10px] border-[2px] bg-[#DCFAE6] border-[8px] border-[#ECFDF3]"
          >
            <SvgIcon name="check_circle" />
          </div>
          <img
            src="/images/collection_half_cirle.png"
            class="w-[50%] absolute top-0 left-0"
          />
        </div>
      </template>
      <div class="relative">
        <div class="mt-[20px]">
          <div>
            <div class="mb-[20px]">
              <p class="text-[#344054] text-[14px] mb-[6px]">
                {{ $t('collections.edit.addCollection') }}
              </p>
              <el-select
                v-model="collectionsIdsInput"
                :placeholder="this.$t('all.select')"
                filterable
                size="large"
                class="w-full"
              >
                <el-option
                  v-for="item in collectionsList"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <span class="flex justify-between gap-3 px-5">
          <div
            class="w-[50%] active:outline active:outline-4 active:outline-[#EAECF0] hover:bg-[#F0F2F5] text-center py-[10px] px-4 border border-[#D0D5DD] cursor-pointer shadow-xs rounded-[8px]"
            @click="cancelAddCollections"
          >
            {{ $t('all.cancel') }}
          </div>
          <div
            class="w-[50%] hover:bg-[#223B99] hover:border-[#223B99] active:outline active:outline-4 active:outline-[#D4DbF5] text-[#ffffff] text-center py-[10px] px-4 border border-[#3250BD] bg-[#3250BD] cursor-pointer shadow-xs rounded-[8px]"
            @click="confirmAddCollections"
          >
            {{ $t('all.confirm') }}
          </div>
        </span>
      </template>
    </el-dialog>
  </div>
</template>
<script setup>
  import { ref, inject, onMounted } from 'vue'
  import jwtFetch from '../../packs/jwtFetch'
  import { ElMessage } from 'element-plus'
  import { useI18n } from 'vue-i18n'

  const { t } = useI18n()

  const csghubServer = inject('csghubServer')

  const props = defineProps({
    repoId: String,
    userName: String,
    settingsVisibility: Boolean
  })
  const dialogVisible = ref(false)
  const collectionsList = ref([])
  const collectionsIdsInput = ref('')

  const fetchCollectionsList = async () => {
    const url = `${csghubServer}/api/v1/user/${props.userName}/collections`
    const res = await jwtFetch(url)
    if (!res.ok) {
      const { msg } = await res.json()
      ElMessage({ message: msg, type: 'warning' })
    } else {
      const { data } = await res.json()
      collectionsList.value = data
    }
  }

  const confirmAddCollections = () => {
    if (!collectionsIdsInput.value) {
      ElMessage({ message: t('all.selectProject'), type: 'warning' })
      return
    }
    repoAddToCollections()
  }

  const cancelAddCollections = () => {
    dialogVisible.value = false
    collectionsIdsInput.value = ''
  }

  async function repoAddToCollections() {
    const addRepoData = {
      repo_ids: [props.repoId]
    }
    const options = { method: 'POST', body: JSON.stringify(addRepoData) }
    const url = `${csghubServer}/api/v1/collections/${collectionsIdsInput.value}/repos`
    const response = await jwtFetch(url, options)
    if (!response.ok) {
      ElMessage({ message: (await response.json()).msg, type: 'warning' })
    } else {
      dialogVisible.value = false
      ElMessage({
        message: t('all.addSuccess'),
        type: 'success'
      })
      collectionsIdsInput.value = ''
    }
  }
  onMounted(() => {
    fetchCollectionsList()
  })
</script>
<style>
  @media (max-width: 768px) {
    .AddRepoToCollections .invite_dialog {
      width: 350px;
    }
  }

  .AddRepoToCollections .scroll-container::after {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    width: 8px;
    /* 滚动条宽度 */
    background-color: #ccc;
    /* 滚动条颜色 */
    border-radius: 4px;
    /* 滚动条圆角 */
  }

  .AddRepoToCollections .scroll-container .content {
    padding-right: 8px;
    /* 留出滚动条的空间 */
  }

  .AddRepoToCollections .scroll-container::-webkit-scrollbar {
    width: 8px;
    /* 滚动条宽度 */
  }

  .AddRepoToCollections .scroll-container::-webkit-scrollbar-thumb {
    background-color: #888;
    /* 滚动条thumb颜色 */
    border-radius: 4px;
    /* 滚动条thumb圆角 */
  }
</style>
