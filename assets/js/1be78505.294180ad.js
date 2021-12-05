(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[514,35,126],{64597:function(e,t,n){"use strict";n.r(t),n.d(t,{default:function(){return ae}});var a=n(67294),r=n(3905),o=n(46291),l=n(54814),c=n(10284),i=n(87462),s=n(63366),u=n(12859),d=n(39960),m=n(86010),p={plain:{backgroundColor:"#2a2734",color:"#9a86fd"},styles:[{types:["comment","prolog","doctype","cdata","punctuation"],style:{color:"#6c6783"}},{types:["namespace"],style:{opacity:.7}},{types:["tag","operator","number"],style:{color:"#e09142"}},{types:["property","function"],style:{color:"#9a86fd"}},{types:["tag-id","selector","atrule-id"],style:{color:"#eeebff"}},{types:["attr-name"],style:{color:"#c4b9fe"}},{types:["boolean","string","entity","url","attr-value","keyword","control","directive","unit","statement","regex","at-rule","placeholder","variable"],style:{color:"#ffcc99"}},{types:["deleted"],style:{textDecorationLine:"line-through"}},{types:["inserted"],style:{textDecorationLine:"underline"}},{types:["italic"],style:{fontStyle:"italic"}},{types:["important","bold"],style:{fontWeight:"bold"}},{types:["important"],style:{color:"#c4b9fe"}}]},h={Prism:n(87410).default,theme:p};function f(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function v(){return v=Object.assign||function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var a in n)Object.prototype.hasOwnProperty.call(n,a)&&(e[a]=n[a])}return e},v.apply(this,arguments)}var g=/\r\n|\r|\n/,y=function(e){0===e.length?e.push({types:["plain"],content:"\n",empty:!0}):1===e.length&&""===e[0].content&&(e[0].content="\n",e[0].empty=!0)},b=function(e,t){var n=e.length;return n>0&&e[n-1]===t?e:e.concat(t)},k=function(e,t){var n=e.plain,a=Object.create(null),r=e.styles.reduce((function(e,n){var a=n.languages,r=n.style;return a&&!a.includes(t)||n.types.forEach((function(t){var n=v({},e[t],r);e[t]=n})),e}),a);return r.root=n,r.plain=v({},n,{backgroundColor:null}),r};function E(e,t){var n={};for(var a in e)Object.prototype.hasOwnProperty.call(e,a)&&-1===t.indexOf(a)&&(n[a]=e[a]);return n}var Z=function(e){function t(){for(var t=this,n=[],a=arguments.length;a--;)n[a]=arguments[a];e.apply(this,n),f(this,"getThemeDict",(function(e){if(void 0!==t.themeDict&&e.theme===t.prevTheme&&e.language===t.prevLanguage)return t.themeDict;t.prevTheme=e.theme,t.prevLanguage=e.language;var n=e.theme?k(e.theme,e.language):void 0;return t.themeDict=n})),f(this,"getLineProps",(function(e){var n=e.key,a=e.className,r=e.style,o=v({},E(e,["key","className","style","line"]),{className:"token-line",style:void 0,key:void 0}),l=t.getThemeDict(t.props);return void 0!==l&&(o.style=l.plain),void 0!==r&&(o.style=void 0!==o.style?v({},o.style,r):r),void 0!==n&&(o.key=n),a&&(o.className+=" "+a),o})),f(this,"getStyleForToken",(function(e){var n=e.types,a=e.empty,r=n.length,o=t.getThemeDict(t.props);if(void 0!==o){if(1===r&&"plain"===n[0])return a?{display:"inline-block"}:void 0;if(1===r&&!a)return o[n[0]];var l=a?{display:"inline-block"}:{},c=n.map((function(e){return o[e]}));return Object.assign.apply(Object,[l].concat(c))}})),f(this,"getTokenProps",(function(e){var n=e.key,a=e.className,r=e.style,o=e.token,l=v({},E(e,["key","className","style","token"]),{className:"token "+o.types.join(" "),children:o.content,style:t.getStyleForToken(o),key:void 0});return void 0!==r&&(l.style=void 0!==l.style?v({},l.style,r):r),void 0!==n&&(l.key=n),a&&(l.className+=" "+a),l})),f(this,"tokenize",(function(e,t,n,a){var r={code:t,grammar:n,language:a,tokens:[]};e.hooks.run("before-tokenize",r);var o=r.tokens=e.tokenize(r.code,r.grammar,r.language);return e.hooks.run("after-tokenize",r),o}))}return e&&(t.__proto__=e),t.prototype=Object.create(e&&e.prototype),t.prototype.constructor=t,t.prototype.render=function(){var e=this.props,t=e.Prism,n=e.language,a=e.code,r=e.children,o=this.getThemeDict(this.props),l=t.languages[n];return r({tokens:function(e){for(var t=[[]],n=[e],a=[0],r=[e.length],o=0,l=0,c=[],i=[c];l>-1;){for(;(o=a[l]++)<r[l];){var s=void 0,u=t[l],d=n[l][o];if("string"==typeof d?(u=l>0?u:["plain"],s=d):(u=b(u,d.type),d.alias&&(u=b(u,d.alias)),s=d.content),"string"==typeof s){var m=s.split(g),p=m.length;c.push({types:u,content:m[0]});for(var h=1;h<p;h++)y(c),i.push(c=[]),c.push({types:u,content:m[h]})}else l++,t.push(u),n.push(s),a.push(0),r.push(s.length)}l--,t.pop(),n.pop(),a.pop(),r.pop()}return y(c),i}(void 0!==l?this.tokenize(t,a,l,n):[a]),className:"prism-code language-"+n,style:void 0!==o?o.root:{},getLineProps:this.getLineProps,getTokenProps:this.getTokenProps})},t}(a.Component),N=Z;var C=n(87594),S=n.n(C),_={plain:{color:"#bfc7d5",backgroundColor:"#292d3e"},styles:[{types:["comment"],style:{color:"rgb(105, 112, 152)",fontStyle:"italic"}},{types:["string","inserted"],style:{color:"rgb(195, 232, 141)"}},{types:["number"],style:{color:"rgb(247, 140, 108)"}},{types:["builtin","char","constant","function"],style:{color:"rgb(130, 170, 255)"}},{types:["punctuation","selector"],style:{color:"rgb(199, 146, 234)"}},{types:["variable"],style:{color:"rgb(191, 199, 213)"}},{types:["class-name","attr-name"],style:{color:"rgb(255, 203, 107)"}},{types:["tag","deleted"],style:{color:"rgb(255, 85, 114)"}},{types:["operator"],style:{color:"rgb(137, 221, 255)"}},{types:["boolean"],style:{color:"rgb(255, 88, 116)"}},{types:["keyword"],style:{fontStyle:"italic"}},{types:["doctype"],style:{color:"rgb(199, 146, 234)",fontStyle:"italic"}},{types:["namespace"],style:{color:"rgb(178, 204, 214)"}},{types:["url"],style:{color:"rgb(221, 221, 221)"}}]},T=n(85350),x=n(32822),I=function(){var e=(0,x.LU)().prism,t=(0,T.Z)().isDarkTheme,n=e.theme||_,a=e.darkTheme||n;return t?a:n},B=n(95999),P="codeBlockContainer_K1bP",j="codeBlockContent_hGly",L="codeBlockTitle_eoMF",M="codeBlock_23N8",w="copyButton_Ue-o",A="codeBlockLines_39YC",D=/{([\d,-]+)}/,R=["js","jsBlock","jsx","python","html"],F={js:{start:"\\/\\/",end:""},jsBlock:{start:"\\/\\*",end:"\\*\\/"},jsx:{start:"\\{\\s*\\/\\*",end:"\\*\\/\\s*\\}"},python:{start:"#",end:""},html:{start:"\x3c!--",end:"--\x3e"}},O=["highlight-next-line","highlight-start","highlight-end"],W=function(e){void 0===e&&(e=R);var t=e.map((function(e){var t=F[e],n=t.start,a=t.end;return"(?:"+n+"\\s*("+O.join("|")+")\\s*"+a+")"})).join("|");return new RegExp("^\\s*(?:"+t+")\\s*$")};function H(e){var t=e.children,n=e.className,r=e.metastring,o=e.title,l=(0,x.LU)().prism,c=(0,a.useState)(!1),s=c[0],u=c[1],d=(0,a.useState)(!1),p=d[0],f=d[1];(0,a.useEffect)((function(){f(!0)}),[]);var v=(0,x.bc)(r)||o,g=(0,a.useRef)(null),y=[],b=I(),k=Array.isArray(t)?t.join(""):t;if(r&&D.test(r)){var E=r.match(D)[1];y=S()(E).filter((function(e){return e>0}))}var Z=null==n?void 0:n.split(" ").find((function(e){return e.startsWith("language-")})),C=null==Z?void 0:Z.replace(/language-/,"");!C&&l.defaultLanguage&&(C=l.defaultLanguage);var _=k.replace(/\n$/,"");if(0===y.length&&void 0!==C){for(var T,R="",F=function(e){switch(e){case"js":case"javascript":case"ts":case"typescript":return W(["js","jsBlock"]);case"jsx":case"tsx":return W(["js","jsBlock","jsx"]);case"html":return W(["js","jsBlock","html"]);case"python":case"py":return W(["python"]);default:return W()}}(C),O=k.replace(/\n$/,"").split("\n"),H=0;H<O.length;){var z=H+1,U=O[H].match(F);if(null!==U){switch(U.slice(1).reduce((function(e,t){return e||t}),void 0)){case"highlight-next-line":R+=z+",";break;case"highlight-start":T=z;break;case"highlight-end":R+=T+"-"+(z-1)+","}O.splice(H,1)}else H+=1}y=S()(R),_=O.join("\n")}var V=function(){!function(e,t){var n=(void 0===t?{}:t).target,a=void 0===n?document.body:n,r=document.createElement("textarea"),o=document.activeElement;r.value=e,r.setAttribute("readonly",""),r.style.contain="strict",r.style.position="absolute",r.style.left="-9999px",r.style.fontSize="12pt";var l=document.getSelection(),c=!1;l.rangeCount>0&&(c=l.getRangeAt(0)),a.append(r),r.select(),r.selectionStart=0,r.selectionEnd=e.length;var i=!1;try{i=document.execCommand("copy")}catch(s){}r.remove(),c&&(l.removeAllRanges(),l.addRange(c)),o&&o.focus()}(_),u(!0),setTimeout((function(){return u(!1)}),2e3)};return a.createElement(N,(0,i.Z)({},h,{key:String(p),theme:b,code:_,language:C}),(function(e){var t=e.className,r=e.style,o=e.tokens,l=e.getLineProps,c=e.getTokenProps;return a.createElement("div",{className:(0,m.Z)(P,null==n?void 0:n.replace(/language-[^ ]+/,""))},v&&a.createElement("div",{style:r,className:L},v),a.createElement("div",{className:(0,m.Z)(j,C)},a.createElement("pre",{tabIndex:0,className:(0,m.Z)(t,M,"thin-scrollbar"),style:r},a.createElement("code",{className:A},o.map((function(e,t){1===e.length&&"\n"===e[0].content&&(e[0].content="");var n=l({line:e,key:t});return y.includes(t+1)&&(n.className+=" docusaurus-highlight-code-line"),a.createElement("span",(0,i.Z)({key:t},n),e.map((function(e,t){return a.createElement("span",(0,i.Z)({key:t},c({token:e,key:t})))})),a.createElement("br",null))})))),a.createElement("button",{ref:g,type:"button","aria-label":(0,B.I)({id:"theme.CodeBlock.copyButtonAriaLabel",message:"Copy code to clipboard",description:"The ARIA label for copy code blocks button"}),className:(0,m.Z)(w,"clean-btn"),onClick:V},s?a.createElement(B.Z,{id:"theme.CodeBlock.copied",description:"The copied button label on code blocks"},"Copied"):a.createElement(B.Z,{id:"theme.CodeBlock.copy",description:"The copy button label on code blocks"},"Copy"))))}))}var z=n(39649),U="details_1VDD";function V(e){var t=Object.assign({},e);return a.createElement(x.PO,(0,i.Z)({},t,{className:(0,m.Z)("alert alert--info",U,t.className)}))}var Y=["mdxType","originalType"];var $={head:function(e){var t=a.Children.map(e.children,(function(e){return function(e){var t,n;if(null!=e&&null!=(t=e.props)&&t.mdxType&&null!=e&&null!=(n=e.props)&&n.originalType){var r=e.props,o=(r.mdxType,r.originalType,(0,s.Z)(r,Y));return a.createElement(e.props.originalType,o)}return e}(e)}));return a.createElement(u.Z,e,t)},code:function(e){var t=e.children;return(0,a.isValidElement)(t)?t:t.includes("\n")?a.createElement(H,e):a.createElement("code",e)},a:function(e){return a.createElement(d.Z,e)},pre:function(e){var t,n=e.children;return(0,a.isValidElement)(n)&&(0,a.isValidElement)(null==n||null==(t=n.props)?void 0:t.children)?n.props.children:a.createElement(H,(0,a.isValidElement)(n)?null==n?void 0:n.props:Object.assign({},e))},details:function(e){var t=a.Children.toArray(e.children),n=t.find((function(e){var t;return"summary"===(null==e||null==(t=e.props)?void 0:t.mdxType)})),r=a.createElement(a.Fragment,null,t.filter((function(e){return e!==n})));return a.createElement(V,(0,i.Z)({},e,{summary:n}),r)},h1:(0,z.Z)("h1"),h2:(0,z.Z)("h2"),h3:(0,z.Z)("h3"),h4:(0,z.Z)("h4"),h5:(0,z.Z)("h5"),h6:(0,z.Z)("h6")},K=n(24608),J=n(34096),G="backToTopButton_35hR",q="backToTopButtonShow_18ls";function Q(){var e=(0,a.useRef)(null);return{smoothScrollTop:function(){var t;e.current=(t=null,function e(){var n=document.documentElement.scrollTop;n>0&&(t=requestAnimationFrame(e),window.scrollTo(0,Math.floor(.85*n)))}(),function(){return t&&cancelAnimationFrame(t)})},cancelScrollToTop:function(){return null==e.current?void 0:e.current()}}}var X=function(){var e,t=(0,a.useState)(!1),n=t[0],r=t[1],o=(0,a.useRef)(!1),l=Q(),c=l.smoothScrollTop,i=l.cancelScrollToTop;return(0,x.RF)((function(e,t){var n=e.scrollY,a=null==t?void 0:t.scrollY;if(a)if(o.current)o.current=!1;else{var l=n<a;if(l||i(),n<300)r(!1);else if(l){var c=document.documentElement.scrollHeight;n+window.innerHeight<c&&r(!0)}else r(!1)}})),(0,x.SL)((function(e){e.location.hash&&(o.current=!0,r(!1))})),a.createElement("button",{"aria-label":(0,B.I)({id:"theme.BackToTopButton.buttonAriaLabel",message:"Scroll back to top",description:"The ARIA label for the back to top button"}),className:(0,m.Z)("clean-btn",x.kM.common.backToTopButton,G,(e={},e[q]=n,e)),type:"button",onClick:function(){return c()}})},ee=n(76775),te={docPage:"docPage_31aa",docMainContainer:"docMainContainer_3ufF",docSidebarContainer:"docSidebarContainer_3Kbt",docMainContainerEnhanced:"docMainContainerEnhanced_3NYZ",docSidebarContainerHidden:"docSidebarContainerHidden_3pA8",collapsedDocSidebar:"collapsedDocSidebar_2JMH",expandSidebarButtonIcon:"expandSidebarButtonIcon_1naQ",docItemWrapperEnhanced:"docItemWrapperEnhanced_2vyJ"};function ne(e){var t,n,o,i=e.currentDocRoute,s=e.versionMetadata,u=e.children,d=s.pluginId,p=s.version,h=i.sidebar,f=h?s.docsSidebars[h]:void 0,v=(0,a.useState)(!1),g=v[0],y=v[1],b=(0,a.useState)(!1),k=b[0],E=b[1],Z=(0,a.useCallback)((function(){k&&E(!1),y((function(e){return!e}))}),[k]);return a.createElement(l.Z,{wrapperClassName:x.kM.wrapper.docsPages,pageClassName:x.kM.page.docsDocPage,searchMetadatas:{version:p,tag:(0,x.os)(d,p)}},a.createElement("div",{className:te.docPage},a.createElement(X,null),f&&a.createElement("aside",{className:(0,m.Z)(te.docSidebarContainer,(t={},t[te.docSidebarContainerHidden]=g,t)),onTransitionEnd:function(e){e.currentTarget.classList.contains(te.docSidebarContainer)&&g&&E(!0)}},a.createElement(c.Z,{key:h,sidebar:f,path:i.path,onCollapse:Z,isHidden:k}),k&&a.createElement("div",{className:te.collapsedDocSidebar,title:(0,B.I)({id:"theme.docs.sidebar.expandButtonTitle",message:"Expand sidebar",description:"The ARIA label and title attribute for expand button of doc sidebar"}),"aria-label":(0,B.I)({id:"theme.docs.sidebar.expandButtonAriaLabel",message:"Expand sidebar",description:"The ARIA label and title attribute for expand button of doc sidebar"}),tabIndex:0,role:"button",onKeyDown:Z,onClick:Z},a.createElement(J.Z,{className:te.expandSidebarButtonIcon}))),a.createElement("main",{className:(0,m.Z)(te.docMainContainer,(n={},n[te.docMainContainerEnhanced]=g||!f,n))},a.createElement("div",{className:(0,m.Z)("container padding-top--md padding-bottom--lg",te.docItemWrapper,(o={},o[te.docItemWrapperEnhanced]=g,o))},a.createElement(r.Zo,{components:$},u)))))}var ae=function(e){var t=e.route.routes,n=e.versionMetadata,r=e.location,l=t.find((function(e){return(0,ee.LX)(r.pathname,e)}));return l?a.createElement(a.Fragment,null,a.createElement(u.Z,null,a.createElement("html",{className:n.className})),a.createElement(ne,{currentDocRoute:l,versionMetadata:n},(0,o.Z)(t,{versionMetadata:n}))):a.createElement(K.default,null)}},10284:function(e,t,n){"use strict";n.d(t,{Z:function(){return F}});var a=n(67294),r=n(86010),o=n(32822),l=n(93783),c=n(55537),i=n(34096),s=n(95999),u=n(87462),d=n(63366),m=n(39960),p=n(13919),h=n(90541),f="menuLinkText_1J2g",v=["items"],g=["item"],y=["item","onItemClick","activePath","level"],b=["item","onItemClick","activePath","level"],k=function e(t,n){return"link"===t.type?(0,o.Mg)(t.href,n):"category"===t.type&&t.items.some((function(t){return e(t,n)}))},E=(0,a.memo)((function(e){var t=e.items,n=(0,d.Z)(e,v);return a.createElement(a.Fragment,null,t.map((function(e,t){return a.createElement(Z,(0,u.Z)({key:t,item:e},n))})))}));function Z(e){var t=e.item,n=(0,d.Z)(e,g);return"category"===t.type?0===t.items.length?null:a.createElement(N,(0,u.Z)({item:t},n)):a.createElement(C,(0,u.Z)({item:t},n))}function N(e){var t,n=e.item,l=e.onItemClick,c=e.activePath,i=e.level,s=(0,d.Z)(e,y),m=n.items,p=n.label,h=n.collapsible,v=n.className,g=k(n,c),b=(0,o.uR)({initialState:function(){return!!h&&(!g&&n.collapsed)}}),Z=b.collapsed,N=b.setCollapsed,C=b.toggleCollapsed;return function(e){var t=e.isActive,n=e.collapsed,r=e.setCollapsed,l=(0,o.D9)(t);(0,a.useEffect)((function(){t&&!l&&n&&r(!1)}),[t,l,n,r])}({isActive:g,collapsed:Z,setCollapsed:N}),a.createElement("li",{className:(0,r.Z)(o.kM.docs.docSidebarItemCategory,o.kM.docs.docSidebarItemCategoryLevel(i),"menu__list-item",{"menu__list-item--collapsed":Z},v)},a.createElement("a",(0,u.Z)({className:(0,r.Z)("menu__link",(t={"menu__link--sublist":h,"menu__link--active":h&&g},t[f]=!h,t)),onClick:h?function(e){e.preventDefault(),C()}:void 0,href:h?"#":void 0},s),p),a.createElement(o.zF,{lazy:!0,as:"ul",className:"menu__list",collapsed:Z},a.createElement(E,{items:m,tabIndex:Z?-1:0,onItemClick:l,activePath:c,level:i+1})))}function C(e){var t=e.item,n=e.onItemClick,l=e.activePath,c=e.level,i=(0,d.Z)(e,b),s=t.href,f=t.label,v=t.className,g=k(t,l);return a.createElement("li",{className:(0,r.Z)(o.kM.docs.docSidebarItemLink,o.kM.docs.docSidebarItemLinkLevel(c),"menu__list-item",v),key:f},a.createElement(m.Z,(0,u.Z)({className:(0,r.Z)("menu__link",{"menu__link--active":g}),"aria-current":g?"page":void 0,to:s},(0,p.Z)(s)&&{onClick:n},i),(0,p.Z)(s)?f:a.createElement("span",null,f,a.createElement(h.Z,null))))}var S="sidebar_15mo",_="sidebarWithHideableNavbar_267A",T="sidebarHidden_2kNb",x="sidebarLogo_3h0W",I="menu_Bmed",B="menuWithAnnouncementBar_2WvA",P="collapseSidebarButton_1CGd",j="collapseSidebarButtonIcon_3E-R";function L(e){var t=e.onClick;return a.createElement("button",{type:"button",title:(0,s.I)({id:"theme.docs.sidebar.collapseButtonTitle",message:"Collapse sidebar",description:"The title attribute for collapse button of doc sidebar"}),"aria-label":(0,s.I)({id:"theme.docs.sidebar.collapseButtonAriaLabel",message:"Collapse sidebar",description:"The title attribute for collapse button of doc sidebar"}),className:(0,r.Z)("button button--secondary button--outline",P),onClick:t},a.createElement(i.Z,{className:j}))}function M(e){var t,n,l=e.path,i=e.sidebar,s=e.onCollapse,u=e.isHidden,d=function(){var e=(0,o.nT)().isActive,t=(0,a.useState)(e),n=t[0],r=t[1];return(0,o.RF)((function(t){var n=t.scrollY;e&&r(0===n)}),[e]),e&&n}(),m=(0,o.LU)(),p=m.navbar.hideOnScroll,h=m.hideableSidebar;return a.createElement("div",{className:(0,r.Z)(S,(t={},t[_]=p,t[T]=u,t))},p&&a.createElement(c.Z,{tabIndex:-1,className:x}),a.createElement("nav",{className:(0,r.Z)("menu thin-scrollbar",I,(n={},n[B]=d,n))},a.createElement("ul",{className:(0,r.Z)(o.kM.docs.docSidebarMenu,"menu__list")},a.createElement(E,{items:i,activePath:l,level:1}))),h&&a.createElement(L,{onClick:s}))}var w=function(e){var t=e.toggleSidebar,n=e.sidebar,l=e.path;return a.createElement("ul",{className:(0,r.Z)(o.kM.docs.docSidebarMenu,"menu__list")},a.createElement(E,{items:n,activePath:l,onItemClick:function(){return t()},level:1}))};function A(e){return a.createElement(o.Cv,{component:w,props:e})}var D=a.memo(M),R=a.memo(A);function F(e){var t=(0,l.Z)(),n="desktop"===t||"ssr"===t,r="mobile"===t;return a.createElement(a.Fragment,null,n&&a.createElement(D,e),r&&a.createElement(R,e))}},39649:function(e,t,n){"use strict";n.d(t,{N:function(){return m},Z:function(){return p}});var a=n(63366),r=n(87462),o=n(67294),l=n(86010),c=n(95999),i=n(32822),s="anchorWithStickyNavbar_31ik",u="anchorWithHideOnScrollNavbar_3R7-",d=["id"],m=function(e){var t=Object.assign({},e);return o.createElement("header",null,o.createElement("h1",(0,r.Z)({},t,{id:void 0}),t.children))},p=function(e){return"h1"===e?m:(t=e,function(e){var n,m=e.id,p=(0,a.Z)(e,d),h=(0,i.LU)().navbar.hideOnScroll;return m?o.createElement(t,(0,r.Z)({},p,{className:(0,l.Z)("anchor",(n={},n[u]=h,n[s]=!h,n)),id:m}),p.children,o.createElement("a",{"aria-hidden":"true",className:"hash-link",href:"#"+m,title:(0,c.I)({id:"theme.common.headingLinkTitle",message:"Direct link to heading",description:"Title for link to heading"})},"\u200b")):o.createElement(t,p)});var t}},34096:function(e,t,n){"use strict";var a=n(87462),r=n(67294);t.Z=function(e){return r.createElement("svg",(0,a.Z)({width:"20",height:"20","aria-hidden":"true"},e),r.createElement("g",{fill:"#7a7a7a"},r.createElement("path",{d:"M9.992 10.023c0 .2-.062.399-.172.547l-4.996 7.492a.982.982 0 01-.828.454H1c-.55 0-1-.453-1-1 0-.2.059-.403.168-.551l4.629-6.942L.168 3.078A.939.939 0 010 2.528c0-.548.45-.997 1-.997h2.996c.352 0 .649.18.828.45L9.82 9.472c.11.148.172.347.172.55zm0 0"}),r.createElement("path",{d:"M19.98 10.023c0 .2-.058.399-.168.547l-4.996 7.492a.987.987 0 01-.828.454h-3c-.547 0-.996-.453-.996-1 0-.2.059-.403.168-.551l4.625-6.942-4.625-6.945a.939.939 0 01-.168-.55 1 1 0 01.996-.997h3c.348 0 .649.18.828.45l4.996 7.492c.11.148.168.347.168.55zm0 0"})))}},24608:function(e,t,n){"use strict";n.r(t);var a=n(67294),r=n(54814),o=n(95999);t.default=function(){return a.createElement(r.Z,{title:(0,o.I)({id:"theme.NotFound.title",message:"Page Not Found"})},a.createElement("main",{className:"container margin-vert--xl"},a.createElement("div",{className:"row"},a.createElement("div",{className:"col col--6 col--offset-3"},a.createElement("h1",{className:"hero__title"},a.createElement(o.Z,{id:"theme.NotFound.title",description:"The title of the 404 page"},"Page Not Found")),a.createElement("p",null,a.createElement(o.Z,{id:"theme.NotFound.p1",description:"The first paragraph of the 404 page"},"We could not find what you were looking for.")),a.createElement("p",null,a.createElement(o.Z,{id:"theme.NotFound.p2",description:"The 2nd paragraph of the 404 page"},"Please contact the owner of the site that linked you to the original URL and let them know their link is broken."))))))}},6979:function(e,t,n){"use strict";var a=n(76775),r=n(52263),o=n(28084),l=n(94184),c=n.n(l),i=n(67294);t.Z=function(e){var t=(0,i.useRef)(!1),l=(0,i.useRef)(null),s=(0,a.k6)(),u=(0,r.Z)().siteConfig,d=(void 0===u?{}:u).baseUrl;(0,i.useEffect)((function(){var e=function(e){"s"!==e.key&&"/"!==e.key||l.current&&e.srcElement===document.body&&(e.preventDefault(),l.current.focus())};return document.addEventListener("keydown",e),function(){document.removeEventListener("keydown",e)}}),[]);var m=(0,o.usePluginData)("docusaurus-lunr-search"),p=function(){t.current||(Promise.all([fetch(""+d+m.fileNames.searchDoc).then((function(e){return e.json()})),fetch(""+d+m.fileNames.lunrIndex).then((function(e){return e.json()})),Promise.all([n.e(878),n.e(245)]).then(n.bind(n,24130)),Promise.all([n.e(532),n.e(343)]).then(n.bind(n,53343))]).then((function(e){var t=e[0],n=e[1],a=e[2].default;0!==t.length&&function(e,t,n){new n({searchDocs:e,searchIndex:t,inputSelector:"#search_input_react",handleSelected:function(e,t,n){var a=d+n.url;document.createElement("a").href=a,s.push(a)}})}(t,n,a)})),t.current=!0)},h=(0,i.useCallback)((function(t){l.current.contains(t.target)||l.current.focus(),e.handleSearchBarToggle&&e.handleSearchBarToggle(!e.isSearchBarExpanded)}),[e.isSearchBarExpanded]);return i.createElement("div",{className:"navbar__search",key:"search-box"},i.createElement("span",{"aria-label":"expand searchbar",role:"button",className:c()("search-icon",{"search-icon-hidden":e.isSearchBarExpanded}),onClick:h,onKeyDown:h,tabIndex:0}),i.createElement("input",{id:"search_input_react",type:"search",placeholder:"Press S to Search...","aria-label":"Search",className:c()("navbar__search-input",{"search-bar-expanded":e.isSearchBarExpanded},{"search-bar":!e.isSearchBarExpanded}),onClick:p,onMouseOver:p,onFocus:h,onBlur:h,ref:l}))}},87594:function(e,t){function n(e){let t,n=[];for(let a of e.split(",").map((e=>e.trim())))if(/^-?\d+$/.test(a))n.push(parseInt(a,10));else if(t=a.match(/^(-?\d+)(-|\.\.\.?|\u2025|\u2026|\u22EF)(-?\d+)$/)){let[e,a,r,o]=t;if(a&&o){a=parseInt(a),o=parseInt(o);const e=a<o?1:-1;"-"!==r&&".."!==r&&"\u2025"!==r||(o+=e);for(let t=a;t!==o;t+=e)n.push(t)}}return n}t.default=n,e.exports=n}}]);