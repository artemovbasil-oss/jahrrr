import React from 'react';

type MobileScreenProps = {
  children: React.ReactNode;
};

function Time() {
  const now = new Date();
  const time = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: false });
  
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="flex flex-row items-center justify-center size-full">
        <div className="content-stretch flex items-center justify-center pl-[16px] pr-[6px] py-0 relative w-full">
          <p className="font-['SF_Pro',sans-serif] font-semibold leading-[22px] relative shrink-0 text-[17px] text-black text-center">
            {time}
          </p>
        </div>
      </div>
    </div>
  );
}

function DynamicIslandSpacer() {
  return <div className="h-[10px] shrink-0 w-[124px]" />;
}

function Battery() {
  return (
    <div className="h-[13px] relative shrink-0 w-[27.328px]">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 27.328 13">
        <rect height="12" opacity="0.35" rx="3.8" stroke="black" width="24" x="0.5" y="0.5" />
        <path d="M25.6563 4.33331V8.66665C26.3462 8.35193 26.8281 7.65874 26.8281 6.84998V6.14998C26.8281 5.34121 26.3462 4.64803 25.6563 4.33331Z" fill="black" opacity="0.4" />
        <rect fill="black" height="9" rx="2.5" width="21" x="2" y="2" />
      </svg>
    </div>
  );
}

function Levels() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="flex flex-row items-center justify-center size-full">
        <div className="content-stretch flex gap-[7px] items-center justify-center pl-[6px] pr-[16px] py-0 relative w-full">
          <div className="h-[12.226px] relative shrink-0 w-[19.2px]">
            <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 19.2 12.2264">
              <path fillRule="evenodd" clipRule="evenodd" d="M17.6 0C18.4837 0 19.2 0.71634 19.2 1.6V10.6264C19.2 11.5101 18.4837 12.2264 17.6 12.2264H16.8C15.9163 12.2264 15.2 11.5101 15.2 10.6264V1.6C15.2 0.71634 15.9163 0 16.8 0H17.6ZM12 2.8C12.8837 2.8 13.6 3.51634 13.6 4.4V10.6264C13.6 11.5101 12.8837 12.2264 12 12.2264H11.2C10.3163 12.2264 9.6 11.5101 9.6 10.6264V4.4C9.6 3.51634 10.3163 2.8 11.2 2.8H12ZM6.4 5.6C7.28366 5.6 8 6.31634 8 7.2V10.6264C8 11.5101 7.28366 12.2264 6.4 12.2264H5.6C4.71634 12.2264 4 11.5101 4 10.6264V7.2C4 6.31634 4.71634 5.6 5.6 5.6H6.4ZM0.8 8.4C1.68366 8.4 2.4 9.11634 2.4 10V10.6264C2.4 11.5101 1.68366 12.2264 0.8 12.2264H0C0 11.5101 0 10.6264 0 10.6264V10C0 9.11634 0 8.4 0.8 8.4Z" fill="black" />
            </svg>
          </div>
          <div className="h-[12.328px] relative shrink-0 w-[17.142px]">
            <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17.1417 12.3283">
              <path fillRule="evenodd" clipRule="evenodd" d="M8.57083 0C13.3029 0 17.1417 3.29933 17.1417 7.36417C17.1417 7.74275 16.8286 8.05083 16.4438 8.05083C16.059 8.05083 15.7458 7.74275 15.7458 7.36417C15.7458 4.05858 12.5319 1.37333 8.57083 1.37333C4.60979 1.37333 1.39583 4.05858 1.39583 7.36417C1.39583 7.74275 1.08267 8.05083 0.697917 8.05083C0.313167 8.05083 0 7.74275 0 7.36417C0 3.29933 3.83879 0 8.57083 0ZM8.57083 3.43667C11.3923 3.43667 13.6833 5.58542 13.6833 8.235C13.6833 8.61358 13.3702 8.92167 12.9854 8.92167C12.6006 8.92167 12.2875 8.61358 12.2875 8.235C12.2875 6.34467 10.6213 4.81 8.57083 4.81C6.52038 4.81 4.85417 6.34467 4.85417 8.235C4.85417 8.61358 4.541 8.92167 4.15625 8.92167C3.7715 8.92167 3.45833 8.61358 3.45833 8.235C3.45833 5.58542 5.74933 3.43667 8.57083 3.43667ZM8.57083 6.87333C9.48138 6.87333 10.2208 7.58875 10.2208 8.46833C10.2208 9.34792 9.48138 10.0633 8.57083 10.0633C7.66029 10.0633 6.92083 9.34792 6.92083 8.46833C6.92083 7.58875 7.66029 6.87333 8.57083 6.87333Z" fill="black" />
            </svg>
          </div>
          <Battery />
        </div>
      </div>
    </div>
  );
}

function StatusBarIPhone() {
  return (
    <div className="content-stretch flex flex-col h-[50px] items-start pb-0 pt-[21px] px-0 relative shrink-0 w-full">
      <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
        <Time />
        <DynamicIslandSpacer />
        <Levels />
      </div>
    </div>
  );
}

function HomeIndicator() {
  return (
    <div className="h-[34px] relative shrink-0 w-full">
      <div className="absolute bottom-[8px] flex h-[5px] items-center justify-center left-1/2 translate-x-[-50%] w-[144px]">
        <div className="bg-black h-[5px] rounded-[100px] w-[144px]" />
      </div>
    </div>
  );
}

export function MobileScreen({ children }: MobileScreenProps) {
  return (
    <div className="bg-[#f0f0f0] content-stretch flex items-start overflow-clip relative rounded-[44px] w-[440px] h-[900px] mx-auto shadow-2xl">
      <div className="content-stretch flex flex-col h-full items-start relative w-full">
        <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-h-px min-w-px pb-[16px] pt-0 px-0 relative w-full overflow-hidden">
          <StatusBarIPhone />
          {children}
        </div>
        <HomeIndicator />
      </div>
    </div>
  );
}
