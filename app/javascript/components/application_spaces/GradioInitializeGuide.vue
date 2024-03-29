<template>
  <div class="sm:px-[20px]">
    <div class="flex gap-[8px] mt-[32px] p-[16px] border border-[#D0D5DD] rounded-[12px] shadow-xs">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
        <g clip-path="url(#clip0_8790_36855)">
          <path d="M6.24984 9.99984L8.74984 12.4998L13.7498 7.49984M18.3332 9.99984C18.3332 14.6022 14.6022 18.3332 9.99984 18.3332C5.39746 18.3332 1.6665 14.6022 1.6665 9.99984C1.6665 5.39746 5.39746 1.6665 9.99984 1.6665C14.6022 1.6665 18.3332 5.39746 18.3332 9.99984Z" stroke="#079455" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
        </g>
        <defs>
          <clipPath id="clip0_8790_36855">
            <rect width="20" height="20" fill="white"/>
          </clipPath>
        </defs>
      </svg>
      <div>
        <h3 class="text-[#475467] text-[14px] font-[500]">{{ $t('application_spaces.gradioGuide.notice') }}</h3>
        <p class="text-[#475467] text-[14px]">{{ $t('application_spaces.gradioGuide.noticeDesc') }}</p>
      </div>
    </div>
    <h3 class="my-[24px] text-[#475467] font-[500]">1. {{ $t('application_spaces.gradioGuide.cloneTitle') }}</h3>
    <div>
      <p class="">
        <span class="px-[12px] py-[8px] cursor-pointer"
              :class="isHttpsTab ? 'active-tab' : ''"
              data-value="https"
              ref="httpsTab"
              @click="toggleActiveTab">
              HTTPS
        </span>
        <span class="px-[12px] py-[8px] cursor-pointer"
              data-value="ssh"
              :class="isHttpsTab ? '' : 'active-tab'"
              ref="sshTab"
              @click="toggleActiveTab">
              SSH
        </span>
      </p>
      <div v-if="isHttpsTab">
        <div class="my-[16px] flex items-center gap-[8px]">
          <div class="h-[16px] w-[16px] flex p-[2px] justify-center items-center rounded-[4px] border border-[#3250BD] bg-[#3250BD]">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12" fill="none">
              <path d="M10 3L4.5 8.5L2 6" stroke="white" stroke-width="1.6666" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          使用我的 token
        </div>
        <div class="px-[16px] py-[8px] bg-[#F9FAFB] rounded-[8px]">
          <pre class="overflow-scroll"><code v-html="highlightedHttpsCloneCode"></code></pre>
        </div>
      </div>
      <div v-else
          class="px-[16px] py-[8px] bg-[#F9FAFB] rounded-[8px] my-[16px]">
        <pre class="overflow-scroll"><code v-html="highlightedSshCloneCode"></code></pre>
      </div>
    </div>
    <h3 class="my-[24px] text-[#475467] font-[500]">2. {{ $t('application_spaces.gradioGuide.createTitle') }}</h3>
    <div class="px-[16px] py-[8px] bg-[#F9FAFB] rounded-[8px]">
      <pre class="overflow-scroll"><code v-html="highlightedAppPyCode"></code></pre>
    </div>
    <h3 class="my-[24px] text-[#475467] font-[500]">3. {{ $t('application_spaces.gradioGuide.submitTitle') }}</h3>
    <div class="px-[16px] py-[8px] bg-[#F9FAFB] rounded-[8px]">
      <pre class="overflow-scroll"><code v-html="highlightedPushCode"></code></pre>
    </div>
    <p class="text-[#667085] text-[16px] font-[400] my-[24px]">{{ $t('application_spaces.gradioGuide.successNotes') }}</p>
    <div class="text-[16px] text-[#667085] border border-[#D0D5DD] rounded-[8px] shadow-xs py-[12px] px-[14px] mb-[32px]">
      <div>
        <h3 class="text-[#101828]"> {{ $t('application_spaces.gradioGuide.dependencyNotesTitle') }} </h3>
        <p>{{ $t('application_spaces.gradioGuide.dependencyNotes1') }}</p>
        <p>{{ $t('application_spaces.gradioGuide.dependencyNotes2') }}</p>
        <p>{{ $t('application_spaces.gradioGuide.dependencyNotes3') }}</p>
      </div>
      <br />
      <div>
        <h3 class="text-[#101828]"> {{ $t('application_spaces.gradioGuide.docNotesTitle') }} </h3>
        <p>{{ $t('application_spaces.gradioGuide.docNotes1') }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { ref } from 'vue'
  import CodeViewer from '../shared/viewers/CodeViewer.vue';
  import hljs from 'highlight.js';
  import 'highlight.js/styles/atom-one-light.css';

  const props = defineProps({
    httpCloneUrl: String,
    sshCloneUrl: String,
  })

  const isHttpsTab = ref(true)
  const httpsTab = ref()
  const sshTab = ref()
  const httpsCloneCode = `git clone ${props.httpCloneUrl}`
  const sshCloneCode = `git clone ${props.sshCloneUrl}`
  const highlightedHttpsCloneCode = hljs.highlight(httpsCloneCode, { language: 'bash', ignoreIllegals: true }).value
  const highlightedSshCloneCode = hljs.highlight(sshCloneCode, { language: 'bash', ignoreIllegals: true }).value

  const appPyCode = `
  import gradio as gr

  def greet(name):
    return "Hello " + name + "!!"

  iface = gr.Interface(fn=greet, inputs="text", outputs="text")
  iface.launch()
  `

  const highlightedAppPyCode = hljs.highlight(appPyCode, { language: 'python', ignoreIllegals: true }).value

  const pushCode = `
  $ git add app.py
  $ git commit -m "Add application file"
  $ git push
  `
  const highlightedPushCode = hljs.highlight(pushCode, { language: 'bash', ignoreIllegals: true }).value

  const toggleActiveTab = (event) => {
    const currentTarget = event.target
    if (currentTarget.dataset.value === 'https') {
      isHttpsTab.value = true
    } else {
      isHttpsTab.value = false
    }
  }
</script>

<style scoped>
  .active-tab {
    border-radius: 6px;
    background: var(--Gray-50, #F9FAFB);
  }
</style>