<template>
  <div class="">
    <img src="/images/Background-pattern-decorative.svg" alt="Background Pattern Decorative" class="absolute left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 z-[-1] w-full max-w-[768px] sm:max-w-[480px]" />

    <div class="h-[calc(100vh-80px)] min-h-[500px] flex items-center justify-center m-auto">
      <div class="flex flex-col items-center" style="position: relative; display: flex; flex-direction: column; justify-content: center; text-align: center; padding: 40px;">
        <div class="Badge h-14 px-3.5 py-3.5 bg-white rounded-lg shadow-[0px_1px_2px_0px_rgba(16,24,40,0.05)] border border-gray-200 justify-start items-center gap-1.5 inline-flex">
          <div class="flex items-center justify-center w-7 h-7">
            <img src="/images/icons/lock-01.svg" alt="Lock" />
          </div>
        </div>

        <h1 id="error-Header" class="error-Header" style="font-size: 60px; font-weight: 500; margin-bottom: 24px; color: #101828;">
          {{ $t('errors_page.unauthorized.title') }}
        </h1>    

        <p id="error-Description" class="error-Description" style="font-size: 20px; margin-bottom: 48px; color: #475467;">
          {{ $t('errors_page.unauthorized.desc') }}
        </p>

        <div id="error-button" class="error-button" style="display: flex; gap: 20px;">
          <a href="javascript:history.back();" class="btn btn-secondary"
            style="background-color: #fff; padding: 16px 24px; font-weight: 500; color: #344054; border: 1px solid #D0D5DD;" 
            onmouseover="this.style.backgroundColor='#F9FAFB'; this.style.color='#344054';"
            onmouseout="this.style.backgroundColor='#fff'; this.style.color='#344054';">
            {{ $t('errors_page.not_found.back') }}
          </a>

          <a href="/" class="btn btn-primary"
            style="background-color: #3250BD; font-weight: 500; color: #fff; padding: 16px 24px;"
            onmouseover="this.style.backgroundColor='#223B99'; this.style.color='white';"
            onmouseout="this.style.backgroundColor='#3250BD'; this.style.color='#fff';">
            {{ $t('errors_page.not_found.home') }}
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>

</script>