;(function () {
  const defaultData = {
    id: '1',
    show_guide: false,
    float_icon: '',
    domain_url: 'http://localhost:5173/',
    header_font_color: 'rgb(100, 106, 115)',
    x_type: 'right',
    y_type: 'bottom',
    x_value: '-5',
    y_value: '33',
  }
  const script_id_prefix = 'sqlbot-assistant-float-script-'
  const guideHtml = `
<div class="sqlbot-assistant-mask">
  <div class="sqlbot-assistant-content"></div>
</div>
<div class="sqlbot-assistant-tips">
  <div class="sqlbot-assistant-close">
    <svg style="vertical-align: middle;overflow: hidden;" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M9.95317 8.73169L15.5511 3.13376C15.7138 2.97104 15.9776 2.97104 16.1403 3.13376L16.7296 3.72301C16.8923 3.88573 16.8923 4.14955 16.7296 4.31227L11.1317 9.9102L16.7296 15.5081C16.8923 15.6708 16.8923 15.9347 16.7296 16.0974L16.1403 16.6866C15.9776 16.8494 15.7138 16.8494 15.5511 16.6866L9.95317 11.0887L4.35524 16.6866C4.19252 16.8494 3.9287 16.8494 3.76598 16.6866L3.17673 16.0974C3.01401 15.9347 3.01401 15.6708 3.17673 15.5081L8.77465 9.9102L3.17673 4.31227C3.01401 4.14955 3.01401 3.88573 3.17673 3.72301L3.76598 3.13376C3.9287 2.97104 4.19252 2.97104 4.35524 3.13376L9.95317 8.73169Z" fill="#ffffff"></path>
    </svg>
  </div>
 
  <div class="sqlbot-assistant-title"> 🌟 遇见问题，不再有障碍！</div>
  <p>你好，我是你的智能小助手。<br/>
      点我，开启高效解答模式，让问题变成过去式。</p>
  <div class="sqlbot-assistant-button">
      <button>我知道了</button>
  </div>
  <span class="sqlbot-assistant-arrow" ></span>
</div>
`

  const chatButtonHtml = (data) => `
<div class="sqlbot-assistant-chat-button">
  <img style="height:100%;width:100%;" src="${data.float_icon}">
</div>`

  const getChatContainerHtml = (data) => {
    return `
<div id="sqlbot-assistant-chat-container">
  <iframe id="sqlbot-assistant-chat" allow="microphone" src="${data.domain_url}#/assistant?id=${data.id}"></iframe>
<div class="sqlbot-assistant-operate">
  <div class="sqlbot-assistant-closeviewport sqlbot-assistant-viewportnone">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M7.507 11.6645C7.73712 11.6645 7.94545 11.7578 8.09625 11.9086C8.24706 12.0594 8.34033 12.2677 8.34033 12.4978V16.7976C8.34033 17.0277 8.15378 17.2143 7.92366 17.2143H7.09033C6.86021 17.2143 6.67366 17.0277 6.67366 16.7976V14.5812L3.41075 17.843C3.24803 18.0057 2.98421 18.0057 2.82149 17.843L2.23224 17.2537C2.06952 17.091 2.06952 16.8272 2.23224 16.6645L5.56668 13.3311H3.19634C2.96622 13.3311 2.77967 13.1446 2.77967 12.9145V12.0811C2.77967 11.851 2.96622 11.6645 3.19634 11.6645H7.507ZM16.5991 2.1572C16.7619 1.99448 17.0257 1.99448 17.1884 2.1572L17.7777 2.74645C17.9404 2.90917 17.9404 3.17299 17.7777 3.33571L14.4432 6.66904H16.8136C17.0437 6.66904 17.2302 6.85559 17.2302 7.08571V7.91904C17.2302 8.14916 17.0437 8.33571 16.8136 8.33571H12.5029C12.2728 8.33571 12.0644 8.24243 11.9136 8.09163C11.7628 7.94082 11.6696 7.73249 11.6696 7.50237V3.20257C11.6696 2.97245 11.8561 2.7859 12.0862 2.7859H12.9196C13.1497 2.7859 13.3362 2.97245 13.3362 3.20257V5.419L16.5991 2.1572Z" fill="${data.header_font_color}"/>
    </svg>
  </div>
  <div class="sqlbot-assistant-openviewport">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
    <path d="M7.15209 11.5968C7.31481 11.4341 7.57862 11.4341 7.74134 11.5968L8.3306 12.186C8.49332 12.3487 8.49332 12.6126 8.3306 12.7753L4.99615 16.1086H7.3665C7.59662 16.1086 7.78316 16.2952 7.78316 16.5253V17.3586C7.78316 17.5887 7.59662 17.7753 7.3665 17.7753H3.05584C2.82572 17.7753 2.61738 17.682 2.46658 17.5312C2.31578 17.3804 2.2225 17.1721 2.2225 16.9419V12.6421C2.2225 12.412 2.40905 12.2255 2.63917 12.2255H3.4725C3.70262 12.2255 3.88917 12.412 3.88917 12.6421V14.8586L7.15209 11.5968ZM16.937 2.22217C17.1671 2.22217 17.3754 2.31544 17.5262 2.46625C17.677 2.61705 17.7703 2.82538 17.7703 3.0555V7.35531C17.7703 7.58543 17.5837 7.77198 17.3536 7.77198H16.5203C16.2902 7.77198 16.1036 7.58543 16.1036 7.35531V5.13888L12.8407 8.40068C12.678 8.5634 12.4142 8.5634 12.2515 8.40068L11.6622 7.81142C11.4995 7.64871 11.4995 7.38489 11.6622 7.22217L14.9966 3.88883H12.6263C12.3962 3.88883 12.2096 3.70229 12.2096 3.47217V2.63883C12.2096 2.40872 12.3962 2.22217 12.6263 2.22217H16.937Z" fill="${data.header_font_color}"/>
    </svg>
  </div>
  <div class="sqlbot-assistant-chat-close">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M9.95317 8.73169L15.5511 3.13376C15.7138 2.97104 15.9776 2.97104 16.1403 3.13376L16.7296 3.72301C16.8923 3.88573 16.8923 4.14955 16.7296 4.31227L11.1317 9.9102L16.7296 15.5081C16.8923 15.6708 16.8923 15.9347 16.7296 16.0974L16.1403 16.6866C15.9776 16.8494 15.7138 16.8494 15.5511 16.6866L9.95317 11.0887L4.35524 16.6866C4.19252 16.8494 3.9287 16.8494 3.76598 16.6866L3.17673 16.0974C3.01401 15.9347 3.01401 15.6708 3.17673 15.5081L8.77465 9.9102L3.17673 4.31227C3.01401 4.14955 3.01401 3.88573 3.17673 3.72301L3.76598 3.13376C3.9287 2.97104 4.19252 2.97104 4.35524 3.13376L9.95317 8.73169Z" fill="${data.header_font_color}"/>
    </svg>
  </div>
</div>
`
  }
  /**
   * 初始化引导
   * @param {*} root
   */
  const initGuide = (root) => {
    root.insertAdjacentHTML('beforeend', guideHtml)
    const button = root.querySelector('.sqlbot-assistant-button')
    const close_icon = root.querySelector('.sqlbot-assistant-close')
    const close_func = () => {
      root.removeChild(root.querySelector('.sqlbot-assistant-tips'))
      root.removeChild(root.querySelector('.sqlbot-assistant-mask'))
      localStorage.setItem('sqlbot_assistant_mask_tip', true)
    }
    button.onclick = close_func
    close_icon.onclick = close_func
  }
  const initChat = (root, data) => {
    // 添加对话icon
    root.insertAdjacentHTML('beforeend', chatButtonHtml(data))
    // 添加对话框
    root.insertAdjacentHTML('beforeend', getChatContainerHtml(data))
    // 按钮元素
    const chat_button = root.querySelector('.sqlbot-assistant-chat-button')
    const chat_button_img = root.querySelector('.sqlbot-assistant-chat-button > img')
    //  对话框元素
    const chat_container = root.querySelector('#sqlbot-assistant-chat-container')
    // 引导层
    const mask_content = root.querySelector('.sqlbot-assistant-mask > .sqlbot-assistant-content')
    const mask_tips = root.querySelector('.sqlbot-assistant-tips')
    chat_button_img.onload = (event) => {
      if (mask_content) {
        mask_content.style.width = chat_button_img.width + 'px'
        mask_content.style.height = chat_button_img.height + 'px'
        if (data.x_type == 'left') {
          mask_tips.style.marginLeft =
            (chat_button_img.naturalWidth > 500 ? 500 : chat_button_img.naturalWidth) - 64 + 'px'
        } else {
          mask_tips.style.marginRight =
            (chat_button_img.naturalWidth > 500 ? 500 : chat_button_img.naturalWidth) - 64 + 'px'
        }
      }
    }

    const viewport = root.querySelector('.sqlbot-assistant-openviewport')
    const closeviewport = root.querySelector('.sqlbot-assistant-closeviewport')
    const close_func = () => {
      chat_container.style['display'] =
        chat_container.style['display'] == 'block' ? 'none' : 'block'
      chat_button.style['display'] = chat_container.style['display'] == 'block' ? 'none' : 'block'
    }
    close_icon = chat_container.querySelector('.sqlbot-assistant-chat-close')
    chat_button.onclick = close_func
    close_icon.onclick = close_func
    const viewport_func = () => {
      if (chat_container.classList.contains('sqlbot-assistant-enlarge')) {
        chat_container.classList.remove('sqlbot-assistant-enlarge')
        viewport.classList.remove('sqlbot-assistant-viewportnone')
        closeviewport.classList.add('sqlbot-assistant-viewportnone')
      } else {
        chat_container.classList.add('sqlbot-assistant-enlarge')
        viewport.classList.add('sqlbot-assistant-viewportnone')
        closeviewport.classList.remove('sqlbot-assistant-viewportnone')
      }
    }
    const drag = (e) => {
      if (['touchmove', 'touchstart'].includes(e.type)) {
        chat_button.style.top = e.touches[0].clientY - chat_button_img.naturalHeight / 2 + 'px'
        chat_button.style.left = e.touches[0].clientX - chat_button_img.naturalWidth / 2 + 'px'
      } else {
        chat_button.style.top = e.y - chat_button_img.naturalHeight / 2 + 'px'
        chat_button.style.left = e.x - chat_button_img.naturalWidth / 2 + 'px'
      }
      chat_button.style.width = chat_button_img.naturalWidth + 'px'
      chat_button.style.height = chat_button_img.naturalHeight + 'px'
    }
    if (data.is_draggable) {
      chat_button.addEventListener('drag', drag)
      chat_button.addEventListener('dragover', (e) => {
        e.preventDefault()
      })
      chat_button.addEventListener('dragend', drag)
      chat_button.addEventListener('touchstart', drag)
      chat_button.addEventListener('touchmove', drag)
    }
    viewport.onclick = viewport_func
    closeviewport.onclick = viewport_func
  }
  /**
   * 第一次进来的引导提示
   */
  function initsqlbot_assistant(data) {
    const sqlbot_div = document.createElement('div')
    const root = document.createElement('div')
    const sqlbot_root_id = 'sqlbot-assistant-root-' + data.id
    root.id = sqlbot_root_id
    initsqlbot_assistantStyle(sqlbot_div, sqlbot_root_id, data)
    sqlbot_div.appendChild(root)
    document.body.appendChild(sqlbot_div)
    const sqlbot_assistant_mask_tip = localStorage.getItem('sqlbot_assistant_mask_tip')
    if (sqlbot_assistant_mask_tip == null && data.show_guide) {
      initGuide(root)
    }
    initChat(root, data)
  }

  // 初始化全局样式
  function initsqlbot_assistantStyle(root, sqlbot_assistantId, data) {
    style = document.createElement('style')
    style.type = 'text/css'
    style.innerText = `
  /* 放大 */
  #sqlbot-assistant .sqlbot-assistant-enlarge {
      width: 50%!important;
      height: 100%!important;
      bottom: 0!important;
      right: 0 !important;
  }
  @media only screen and (max-width: 768px){
  #sqlbot-assistant .sqlbot-assistant-enlarge {
      width: 100%!important;
      height: 100%!important;
      right: 0 !important;
      bottom: 0!important;
  }
  }
  
  /* 引导 */
  
  #sqlbot-assistant .sqlbot-assistant-mask {
      position: fixed;
      z-index: 10001;
      background-color: transparent;
      height: 100%;
      width: 100%;
      top: 0;
      left: 0;
  }
  #sqlbot-assistant .sqlbot-assistant-mask .sqlbot-assistant-content {
      width: 64px;
      height: 64px;
      box-shadow: 1px 1px 1px 9999px rgba(0,0,0,.6);
      position: absolute;
      ${data.x_type}: ${data.x_value}px;
      ${data.y_type}: ${data.y_value}px;
      z-index: 10001;
  }
  #sqlbot-assistant .sqlbot-assistant-tips {
      position: fixed;
      ${data.x_type}:calc(${data.x_value}px + 75px);
      ${data.y_type}: calc(${data.y_value}px + 0px);
      padding: 22px 24px 24px;
      border-radius: 6px;
      color: #ffffff;
      font-size: 14px;
      background: #3370FF;
      z-index: 10001;
  }
  #sqlbot-assistant .sqlbot-assistant-tips .sqlbot-assistant-arrow {
      position: absolute;
      background: #3370FF;
      width: 10px;
      height: 10px;
      pointer-events: none;
      transform: rotate(45deg);
      box-sizing: border-box;
      /* left  */
      ${data.x_type}: -5px;
      ${data.y_type}: 33px;
      border-left-color: transparent;
      border-bottom-color: transparent
  }
  #sqlbot-assistant .sqlbot-assistant-tips .sqlbot-assistant-title {
      font-size: 20px;
      font-weight: 500;
      margin-bottom: 8px;
  }
  #sqlbot-assistant .sqlbot-assistant-tips .sqlbot-assistant-button {
      text-align: right;
      margin-top: 24px;
  }
  #sqlbot-assistant .sqlbot-assistant-tips .sqlbot-assistant-button button {
      border-radius: 4px;
      background: #FFF;
      padding: 3px 12px;
      color: #3370FF;
      cursor: pointer;
      outline: none;
      border: none;
  }
  #sqlbot-assistant .sqlbot-assistant-tips .sqlbot-assistant-button button::after{
      border: none;
    }
  #sqlbot-assistant .sqlbot-assistant-tips .sqlbot-assistant-close {
      position: absolute;
      right: 20px;
      top: 20px;
      cursor: pointer;
  
  }
  #sqlbot-assistant-chat-container {
        width: 450px;
        height: 600px;
        display:none;
      }
  @media only screen and (max-width: 768px) {
        #sqlbot-assistant-chat-container {
          width: 100%;
          height: 70%;
          right: 0 !important;
        }
      }
      
      #sqlbot-assistant .sqlbot-assistant-chat-button{
        position: fixed;
        ${data.x_type}: ${data.x_value}px;
        ${data.y_type}: ${data.y_value}px;
        cursor: pointer;
        z-index:10000;
    }
    #sqlbot-assistant #sqlbot-assistant-chat-container{
        z-index:10000;position: relative;
              border-radius: 8px;
              border: 1px solid #ffffff;
              background: linear-gradient(188deg, rgba(235, 241, 255, 0.20) 39.6%, rgba(231, 249, 255, 0.20) 94.3%), #EFF0F1;
              box-shadow: 0px 4px 8px 0px rgba(31, 35, 41, 0.10);
              position: fixed;bottom: 16px;right: 16px;overflow: hidden;
    }

     #sqlbot-assistant #sqlbot-assistant-chat-container .sqlbot-assistant-operate{
     top: 18px;
     right: 15px;
     position: absolute;
     display: flex;
     align-items: center;
         line-height: 18px;
     }
    #sqlbot-assistant #sqlbot-assistant-chat-container .sqlbot-assistant-operate .sqlbot-assistant-chat-close{
            margin-left:15px;
            cursor: pointer;
    }
    #sqlbot-assistant #sqlbot-assistant-chat-container .sqlbot-assistant-operate .sqlbot-assistant-openviewport{

            cursor: pointer;
    }
    #sqlbot-assistant #sqlbot-assistant-chat-container .sqlbot-assistant-operate .sqlbot-assistant-closeviewport{

      cursor: pointer;
    }
    #sqlbot-assistant #sqlbot-assistant-chat-container .sqlbot-assistant-viewportnone{
      display:none;
    }
    #sqlbot-assistant #sqlbot-assistant-chat-container #sqlbot-assistant-chat{
     height:100%;
     width:100%;
     border: none;
}
    #sqlbot-assistant #sqlbot-assistant-chat-container {
                animation: appear .4s ease-in-out;
              }
              @keyframes appear {
                from {
                  height: 0;;
                }
        
                to {
                  height: 600px;
                }
              }`.replaceAll('#sqlbot-assistant ', `#${sqlbot_assistantId} `)
    root.appendChild(style)
  }
  function getParam(src, key) {
    const url = new URL(src)
    return url.searchParams.get(key)
  }

  function loadScript(src, id) {
    const domain_url = getDomain(src)
    // const url = `${domain_url}api/v1/system/assistant/validator/${id}`
    /* const url = `http://localhost:8000/api/v1/system/assistant/validator/${id}`
    fetch(url)
      .then((response) => response.json())
      .then((data) => {
        console.log(data)
        const tempData = Object.assign(defaultData, data)
        initsqlbot_assistant(tempData)
      }) */
    initsqlbot_assistant(defaultData)
  }
  function getDomain(src) {
    return src.substring(0, src.indexOf('assistant.js'))
  }
  function init() {
    const sqlbotScripts = document.querySelectorAll(`script[id^="${script_id_prefix}"]`)
    const scriptsArray = Array.from(sqlbotScripts)
    const src_list = scriptsArray.map((script) => script.src)
    src_list.forEach((src) => {
      const id = getParam(src, 'id')
      const propName = script_id_prefix + id + '-state'
      if (window[propName]) {
        return true
      }
      window[propName] = true
      loadScript(src, id)
    })
  }
  window.addEventListener('load', init)
})()
