<template>
  <div class="w-full bg-[#FCFCFD] pt-9 pb-[60px] xl:px-10 md:px-0 md:pb-6 md:h-auto">
    <div class="mx-auto max-w-[1280px]">
      <repo-header
        :private="endpoint.private"
        :name="endpoint.deploy_name"
        :path="endpoint.model_id"
        :appStatus="appStatus"
        :space-resource="endpoint.hardware"
        :avatar="avatar"
        :owner-url="ownerUrl"
        repo-type="endpoint"
        :repoId="endpoint.repository_id"
      />
    </div>
  </div>
  <div class="mx-auto max-w-[1280px] mt-[-40px] xl:px-10 md:px-0">
    <repo-tabs
      :repo-detail="endpoint"
      :appStatus="appStatus"
      :appEndpoint="appEndpoint"
      :current-path="currentPath"
      :default-tab="defaultTab"
      :actionName="actionName"
      :settingsVisibility="canManage"
      :can-write="canWrite"
      repo-type="endpoint"
      :clusterId="endpoint.cluster_id"
      :sku="endpoint.sku"
      :modelId="endpoint.model_id"
      :private="endpoint.private"
      :endpointReplica="endpoint.actual_replica"
      :endpointName="endpoint.deploy_name"
      :endpointId="endpoint.deploy_id"
      :userName="namespace"
      :replicaList="replicaList"
      :path="`${namespace}/${modelName}`"
    />
  </div>
</template>

<script setup>
  import { ref, onMounted, inject, watch, computed } from 'vue'
  import RepoHeader from '../shared/RepoHeader.vue'
  import RepoTabs from '../shared/RepoTabs.vue'
  import { useCookies } from "vue3-cookies";
  import { fetchEventSource } from '@microsoft/fetch-event-source';
  import refreshJWT from '../../packs/refreshJWT.js'
  import useRepoDetailStore from '../../stores/RepoDetailStore'
  import useFetchApi from '../../packs/useFetchApi'

  const { cookies } = useCookies()

  const props = defineProps({
    currentPath: String,
    defaultTab: String,
    actionName: String,
    tags: Object,
    namespace: String,
    modelName: String,
    endpointId: Number
  })

  const currentUser = cookies.get('current_user')

  const canWrite = ref(currentUser === props.namespace)
  // only owner can view endpoint detail, so just set true
  const canManage = ref(true)

  const csghubServer = inject('csghubServer')

  const repoDetailStore = useRepoDetailStore()

  const endpoint = ref({})
  const modelInfo = ref({})

  // const allStatus = ['Building', 'Deploying', 'Startup', 'Running', 'Stopped', 'Sleeping', 'BuildingFailed', 'DeployFailed', 'RuntimeError']

  const appStatus = ref('')
  const appEndpoint = ref('')

  watch(endpoint, (newVal) => {
    const endpointUrl = newVal.endpoint
    if (endpointUrl) {
      if(ENABLE_HTTPS === 'true') {
        appEndpoint.value = `https://${endpointUrl}`
      } else {
        appEndpoint.value = `http://${endpointUrl}`
      }
    }
  })

  const isStatusSSEConnected = ref(false)

  const replicaList = ref([])

  const ownerUrl = computed(() => {
    const { namespace } = modelInfo.value
    if (!namespace) return ''
    const baseUrl = namespace.Type === 'user' ? '/profile/' : '/organizations/'
    return baseUrl + namespace.Path
  })

  const avatar = computed(() => modelInfo.value.namespace?.Avatar || '')

  const fetchModelDetail = async () => {
    const url = `/models/${props.namespace}/${props.modelName}`

    try {
      const { data, error } = await useFetchApi(url).json()

      if (data.value) {
        modelInfo.value = data.value.data
      } else {
        ElMessage({ message: error.value.msg, type: 'warning' })
      }
    } catch (error) {
      console.log(error)
    }
  }

  const fetchRepoDetail = async () => {
    const url = `/models/${props.namespace}/${props.modelName}/run/${props.endpointId}`

    try {
      const { data, error } = await useFetchApi(url).json()

      if (data.value) {
        const json = data.value
        endpoint.value = json.data
        appStatus.value = json.data.status
        repoDetailStore.initialize(json.data)
      } else {
        ElMessage({ message: error.value.msg, type: 'warning' })
      }
    } catch (error) {
      console.log(error.msg)
    }
  }

  const syncEndpointStatus = () => {
    fetchEventSource(`${csghubServer}/api/v1/models/${props.namespace}/${props.modelName}/run/${props.endpointId}/status`, {
      openWhenHidden: true,
      headers: {
        Authorization: `Bearer ${cookies.get('user_token')}`,
      },
      async onopen(response) {
        if (response.ok) {
          console.log('SSE status server connected')
          isStatusSSEConnected.value = true
        }
        else if (response.status === 401) {
          refreshJWT()
        } else if (response.status >= 400 && response.status < 500 && response.status !== 429) {
          console.log('Status Server Connection Error')
          console.log(response.status)
          console.log(response.body)
        } else {
          console.log('Status Server Unknow Error')
          console.log(response.body)
        }
      },
      onmessage(ev) {
        console.log(ev)
        const eventResponse = JSON.parse(ev.data)
        console.log(`SyncStatus: ${eventResponse.status}`)
        console.log(`SyncStatus: ${eventResponse.details && eventResponse.details[0].name}`)
        if (appStatus.value !== eventResponse.status) {
          if (eventResponse.status == 'Running') {
            fetchRepoDetail()
          }
          appStatus.value = eventResponse.status
        }
        if (eventResponse.details) {
          replicaList.value = eventResponse.details
        }
      },
      onerror(err) {
        console.log('Status Server Error:')
        console.log(err)
      }
    })
  }

  onMounted(() => {
    fetchRepoDetail()
    fetchModelDetail()
    console.log(`Endpoint 初始状态：${appStatus.value}`)
    if (isStatusSSEConnected.value === false) {
      syncEndpointStatus()
    }
  })
</script>

<style scoped>
  body {
    background: #fff !important;
  }

  :deep(.el-drawer__header) {
    border-bottom: solid 1px lightgray;
    padding: 10px;
    margin-bottom: 0;
  }

  .active-tab {
    border-radius: 6px;
    background: #E5E7EB;
    padding: 6px;
  }
</style>
