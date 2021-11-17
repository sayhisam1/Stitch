"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[288],{3905:function(e,t,n){n.d(t,{Zo:function(){return l},kt:function(){return m}});var r=n(67294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function s(e,t){if(null==e)return{};var n,r,o=function(e,t){if(null==e)return{};var n,r,o={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var c=r.createContext({}),u=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):a(a({},t),e)),n},l=function(e){var t=u(e.components);return r.createElement(c.Provider,{value:t},e.children)},p={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,o=e.mdxType,i=e.originalType,c=e.parentName,l=s(e,["components","mdxType","originalType","parentName"]),d=u(n),m=o,h=d["".concat(c,".").concat(m)]||d[m]||p[m]||i;return n?r.createElement(h,a(a({ref:t},l),{},{components:n})):r.createElement(h,a({ref:t},l))}));function m(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var i=n.length,a=new Array(i);a[0]=d;var s={};for(var c in t)hasOwnProperty.call(t,c)&&(s[c]=t[c]);s.originalType=e,s.mdxType="string"==typeof e?e:o,a[1]=s;for(var u=2;u<i;u++)a[u]=n[u];return r.createElement.apply(null,a)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},93581:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return s},contentTitle:function(){return c},metadata:function(){return u},toc:function(){return l},default:function(){return d}});var r=n(87462),o=n(63366),i=(n(67294),n(3905)),a=["components"],s={sidebar_position:4},c="FAQ",u={unversionedId:"FAQ",id:"FAQ",isDocsHomePage:!1,title:"FAQ",description:"What is Stitch?",source:"@site/docs/FAQ.md",sourceDirName:".",slug:"/FAQ",permalink:"/Stitch/docs/FAQ",editUrl:"https://github.com/sayhisam1/Stitch/edit/master/docs/FAQ.md",tags:[],version:"current",sidebarPosition:4,frontMatter:{sidebar_position:4},sidebar:"defaultSidebar",previous:{title:"Getting Started",permalink:"/Stitch/docs/GettingStarted"}},l=[{value:"What is Stitch?",id:"what-is-stitch",children:[]},{value:"Why should I use an ECS over Object-Oriented Programming (OOP)?",id:"why-should-i-use-an-ecs-over-object-oriented-programming-oop",children:[]},{value:"I have a question not on this page!",id:"i-have-a-question-not-on-this-page",children:[]}],p={toc:l};function d(e){var t=e.components,n=(0,o.Z)(e,a);return(0,i.kt)("wrapper",(0,r.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("h1",{id:"faq"},"FAQ"),(0,i.kt)("h2",{id:"what-is-stitch"},"What is Stitch?"),(0,i.kt)("p",null,(0,i.kt)("strong",{parentName:"p"},"Stitch")," is a simple and powerful ",(0,i.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Entity_component_system"},"Entity Component System (ECS)")," built specifically for Roblox game development. "),(0,i.kt)("p",null,"Stitch allows you to separate the ",(0,i.kt)("strong",{parentName:"p"},"data")," and ",(0,i.kt)("strong",{parentName:"p"},"behavior")," of things in your game. This means your code will be easier to understand and update, and more performant."),(0,i.kt)("h2",{id:"why-should-i-use-an-ecs-over-object-oriented-programming-oop"},"Why should I use an ECS over Object-Oriented Programming (OOP)?"),(0,i.kt)("p",null,"Using an ECS can save you from complex code that arises due to the ",(0,i.kt)("a",{parentName:"p",href:"https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem"},"diamond inheritance problem")," in large object-oriented games. Using OOP, you will likely run into scenarios where the diamond problem is impossible to avoid without structuring your entire game. ECS solves this issue by removing inheritance altogether - instead, you compose many different components on a single entity. This makes it easy to grow your codebase and rapidly add new features."),(0,i.kt)("p",null,"However, ECS and OOP aren't mutually exclusive - you can (and should!) use a mix of both when it's easier."),(0,i.kt)("h2",{id:"i-have-a-question-not-on-this-page"},"I have a question not on this page!"),(0,i.kt)("p",null,"Awesome! Feel free to message me on Discord (sayhisam1#7705), or make an issue on the repository with your question."))}d.isMDXComponent=!0}}]);