import svgPaths from "./svg-uto24a9sgw";

function Time() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative" data-name="Time">
      <div className="flex flex-row items-center justify-center size-full">
        <div className="content-stretch flex items-center justify-center pl-[16px] pr-[6px] py-0 relative w-full">
          <p className="css-ew64yg font-['SF_Pro:Semibold',sans-serif] font-[590] leading-[22px] relative shrink-0 text-[17px] text-black text-center" style={{ fontVariationSettings: "'wdth' 100" }}>
            9:41
          </p>
        </div>
      </div>
    </div>
  );
}

function DynamicIslandSpacer() {
  return <div className="h-[10px] shrink-0 w-[124px]" data-name="Dynamic Island spacer" />;
}

function Battery() {
  return (
    <div className="h-[13px] relative shrink-0 w-[27.328px]" data-name="Battery">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 27.328 13">
        <g id="Battery">
          <rect height="12" id="Border" opacity="0.35" rx="3.8" stroke="var(--stroke-0, black)" width="24" x="0.5" y="0.5" />
          <path d={svgPaths.p3bbd9700} fill="var(--fill-0, black)" id="Cap" opacity="0.4" />
          <rect fill="var(--fill-0, black)" height="9" id="Capacity" rx="2.5" width="21" x="2" y="2" />
        </g>
      </svg>
    </div>
  );
}

function Levels() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative" data-name="Levels">
      <div className="flex flex-row items-center justify-center size-full">
        <div className="content-stretch flex gap-[7px] items-center justify-center pl-[6px] pr-[16px] py-0 relative w-full">
          <div className="h-[12.226px] relative shrink-0 w-[19.2px]" data-name="Cellular Connection">
            <div className="absolute inset-0" style={{ "--fill-0": "rgba(0, 0, 0, 1)" } as React.CSSProperties}>
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 19.2 12.2264">
                <path clipRule="evenodd" d={svgPaths.p1e09e400} fill="var(--fill-0, black)" fillRule="evenodd" id="Cellular Connection" />
              </svg>
            </div>
          </div>
          <div className="h-[12.328px] relative shrink-0 w-[17.142px]" data-name="Wifi">
            <div className="absolute inset-0" style={{ "--fill-0": "rgba(0, 0, 0, 1)" } as React.CSSProperties}>
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17.1417 12.3283">
                <path clipRule="evenodd" d={svgPaths.p18b35300} fill="var(--fill-0, black)" fillRule="evenodd" id="Wifi" />
              </svg>
            </div>
          </div>
          <Battery />
        </div>
      </div>
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="Frame">
      <Time />
      <DynamicIslandSpacer />
      <Levels />
    </div>
  );
}

function StatusBarIPhone() {
  return (
    <div className="content-stretch flex flex-col h-[50px] items-start pb-0 pt-[21px] px-0 relative shrink-0 w-full" data-name="Status Bar - iPhone">
      <Frame />
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex h-[35.998px] items-start relative shrink-0 w-full" data-name="Heading 1">
      <p className="css-4hzbpn flex-[1_0_0] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[36px] min-h-px min-w-px not-italic relative text-[#101828] text-[30px] tracking-[0.3955px]">Hi Basil</p>
    </div>
  );
}

function Container() {
  return (
    <div className="flex-[1_0_0] h-[48px] min-h-px min-w-px relative" data-name="Container">
      <div className="flex flex-col justify-center size-full">
        <div className="content-stretch flex flex-col items-start justify-center px-[15.998px] py-0 relative size-full">
          <Heading />
        </div>
      </div>
    </div>
  );
}

function Icon() {
  return (
    <div className="relative shrink-0 size-[23.993px]" data-name="Icon">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 23.9931 23.9931">
        <g id="Icon">
          <path d={svgPaths.p1a361c00} id="Vector" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d={svgPaths.p3f733e80} id="Vector_2" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
        </g>
      </svg>
    </div>
  );
}

function Button() {
  return (
    <div className="bg-white relative rounded-[16px] shrink-0 size-[48px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <Icon />
      </div>
    </div>
  );
}

function Icon1() {
  return (
    <div className="relative shrink-0 size-[23.993px]" data-name="Icon">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 23.9931 23.9931">
        <g id="Icon">
          <path d="M20.9939 3.99885H13.9959" id="Vector" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M9.99711 3.99885H2.99913" id="Vector_2" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M20.9939 11.9965H11.9965" id="Vector_3" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M7.99769 11.9965H2.99913" id="Vector_4" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M20.9939 19.9942H15.9954" id="Vector_5" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M11.9965 19.9942H2.99913" id="Vector_6" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M13.9959 1.99943V5.99827" id="Vector_7" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M7.99769 9.99712V13.996" id="Vector_8" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
          <path d="M15.9954 17.9948V21.9936" id="Vector_9" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
        </g>
      </svg>
    </div>
  );
}

function Button1() {
  return (
    <div className="bg-white relative rounded-[16px] shrink-0 size-[48px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <Icon1 />
      </div>
    </div>
  );
}

function Container1() {
  return (
    <div className="content-stretch flex gap-[12px] items-center px-[16px] py-0 relative shrink-0" data-name="Container">
      <Button />
      <Button1 />
    </div>
  );
}

function Frame2() {
  return (
    <div className="content-stretch flex items-start pb-0 pt-[16px] px-0 relative shrink-0 w-full">
      <Container />
      <Container1 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex h-[27.995px] items-center relative shrink-0" data-name="Container">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[20px] tracking-[-0.4492px]">Situation</p>
    </div>
  );
}

function Button2() {
  return (
    <div className="bg-[#008236] relative rounded-[14px] shrink-0" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center px-[20px] py-[8px] relative">
        <p className="css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] not-italic relative shrink-0 text-[16px] text-center text-white tracking-[-0.3125px]">✓ This week</p>
      </div>
    </div>
  );
}

function Button3() {
  return (
    <div className="bg-white relative rounded-[14px] shrink-0" data-name="Button">
      <div aria-hidden="true" className="absolute border-[#d1d5dc] border-[0.556px] border-solid inset-0 pointer-events-none rounded-[14px]" />
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center px-[20px] py-[8px] relative">
        <p className="css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] not-italic relative shrink-0 text-[#101828] text-[16px] text-center tracking-[-0.3125px]">This month</p>
      </div>
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex gap-[11.997px] items-start overflow-clip relative shrink-0" data-name="Container">
      <Button2 />
      <Button3 />
    </div>
  );
}

function Container2() {
  return (
    <div className="content-stretch flex items-center justify-between pb-0 pt-[32px] px-[15.998px] relative shrink-0 w-[440px]" data-name="Container">
      <Container3 />
      <Container4 />
    </div>
  );
}

function Heading2() {
  return (
    <div className="content-stretch flex items-center overflow-clip relative shrink-0 w-full" data-name="Heading 3">
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Medium',sans-serif] font-medium leading-[27px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[18px] text-ellipsis tracking-[-0.4395px]">Active projects</p>
    </div>
  );
}

function Container6() {
  return (
    <div className="h-[39.991px] relative shrink-0 w-full" data-name="Container">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[40px] left-0 not-italic text-[#00b8db] text-[36px] top-[0.33px] tracking-[0.3691px]">2</p>
    </div>
  );
}

function StatsCard() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative rounded-[24px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0)]" data-name="StatsCard" style={{ backgroundImage: "linear-gradient(135deg, rgb(224, 238, 245) 63.427%, rgb(131, 175, 197) 171.02%)" }}>
      <div className="content-stretch flex flex-col gap-[3.993px] items-start px-[23.993px] py-[20px] relative w-full">
        <Heading2 />
        <Container6 />
      </div>
    </div>
  );
}

function Heading3() {
  return (
    <div className="content-stretch flex items-center relative shrink-0 w-full" data-name="Heading 3">
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Medium',sans-serif] font-medium leading-[27px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[18px] text-ellipsis tracking-[-0.4395px]">In progress</p>
    </div>
  );
}

function Container7() {
  return (
    <div className="h-[39.991px] relative shrink-0 w-full" data-name="Container">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[40px] left-0 not-italic text-[#00a63e] text-[36px] top-[0.33px] tracking-[0.3691px]">€1,280</p>
    </div>
  );
}

function StatsCard1() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative rounded-[24px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0)]" data-name="StatsCard" style={{ backgroundImage: "linear-gradient(135deg, rgb(240, 245, 224) 63.427%, rgb(150, 202, 73) 171.02%)" }}>
      <div className="content-stretch flex flex-col gap-[3.993px] items-start px-[23.993px] py-[20px] relative w-full">
        <Heading3 />
        <Container7 />
      </div>
    </div>
  );
}

function Container5() {
  return (
    <div className="relative shrink-0 w-full" data-name="Container">
      <div className="content-start flex flex-wrap gap-[15px_16px] items-start pb-0 pt-[16px] px-[16px] relative w-full">
        <StatsCard />
        <StatsCard1 />
      </div>
    </div>
  );
}

function Heading4() {
  return (
    <div className="content-stretch flex items-center overflow-clip relative shrink-0 w-full" data-name="Heading 3">
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Medium',sans-serif] font-medium leading-[27px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[18px] text-ellipsis tracking-[-0.4395px]">Deadlines</p>
    </div>
  );
}

function Container9() {
  return (
    <div className="h-[39.991px] relative shrink-0 w-full" data-name="Container">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[40px] left-0 not-italic text-[#ff6900] text-[36px] top-[0.33px] tracking-[0.3691px]">2</p>
    </div>
  );
}

function StatsCard2() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative rounded-[24px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0)]" data-name="StatsCard" style={{ backgroundImage: "linear-gradient(135deg, rgb(245, 236, 224) 63.427%, rgb(197, 150, 131) 171.02%)" }}>
      <div className="content-stretch flex flex-col gap-[3.993px] items-start px-[23.993px] py-[20px] relative w-full">
        <Heading4 />
        <Container9 />
      </div>
    </div>
  );
}

function Heading5() {
  return (
    <div className="content-stretch flex items-center relative shrink-0 w-full" data-name="Heading 3">
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Medium',sans-serif] font-medium leading-[27px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[18px] text-ellipsis tracking-[-0.4395px]">Payments</p>
    </div>
  );
}

function Container10() {
  return (
    <div className="h-[39.991px] relative shrink-0 w-full" data-name="Container">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[40px] left-0 not-italic text-[#0f0e0e] text-[36px] top-[0.33px] tracking-[0.3691px]">€0</p>
    </div>
  );
}

function StatsCard3() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative rounded-[24px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0)]" data-name="StatsCard" style={{ backgroundImage: "linear-gradient(135deg, rgb(255, 255, 255) 63.427%, rgb(192, 192, 192) 171.02%)" }}>
      <div className="content-stretch flex flex-col gap-[3.993px] items-start px-[23.993px] py-[20px] relative w-full">
        <Heading5 />
        <Container10 />
      </div>
    </div>
  );
}

function Container8() {
  return (
    <div className="relative shrink-0 w-full" data-name="Container">
      <div className="content-start flex flex-wrap gap-[15px_16px] items-start px-[16px] py-0 relative w-full">
        <StatsCard2 />
        <StatsCard3 />
      </div>
    </div>
  );
}

function Frame1() {
  return (
    <div className="content-stretch flex flex-col gap-[16px] items-start relative shrink-0 w-full">
      <Container5 />
      <Container8 />
    </div>
  );
}

function Heading1() {
  return (
    <div className="h-[27.995px] relative shrink-0 w-[212.049px]" data-name="Heading 2">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[20px] top-[-0.33px] tracking-[-0.4492px]">Events</p>
      </div>
    </div>
  );
}

function Button4() {
  return (
    <div className="h-[23.993px] relative shrink-0 w-[56.675px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] left-[28.5px] not-italic text-[#00b8db] text-[16px] text-center top-[-0.78px] tracking-[-0.3125px] translate-x-[-50%]">View all</p>
      </div>
    </div>
  );
}

function Container12() {
  return (
    <div className="content-stretch flex h-[27.995px] items-center justify-between relative shrink-0 w-full" data-name="Container">
      <Heading1 />
      <Button4 />
    </div>
  );
}

function Container14() {
  return (
    <div className="bg-[#434343] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[16px] text-white tracking-[-0.3125px]">NB</p>
      </div>
    </div>
  );
}

function Heading6() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">NDA bank</p>
    </div>
  );
}

function Paragraph() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Retainer</p>
    </div>
  );
}

function Container15() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading6 />
        <Paragraph />
      </div>
    </div>
  );
}

function Container13() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container14 />
      <Container15 />
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€3,500</p>
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="absolute h-[20px] left-0 top-[27.99px] w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-[68.81px] not-italic text-[#4a5565] text-[14px] text-right top-[0.67px] tracking-[-0.1504px] translate-x-[-100%]">Salary</p>
    </div>
  );
}

function Container17() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph1 />
        <Paragraph2 />
      </div>
    </div>
  );
}

function Container16() {
  return (
    <div className="content-stretch flex h-[47.995px] items-center relative shrink-0" data-name="Container">
      <Container17 />
    </div>
  );
}

function Frame5() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container13 />
      <Container16 />
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0 w-[109px]" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">Next payment</p>
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">10.02.2026</p>
    </div>
  );
}

function Frame4() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full">
      <Paragraph3 />
      <div className="flex items-center justify-center relative shrink-0 size-[16px]" style={{ "--transform-inner-width": "0", "--transform-inner-height": "37.765625" } as React.CSSProperties}>
        <div className="flex-none rotate-[90deg]">
          <div className="relative size-[16px]">
            <div className="absolute bottom-1/4 left-[11.26%] right-[11.26%] top-[6.25%]">
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 12.3953 11">
                <path d={svgPaths.p310d0900} fill="var(--fill-0, #A5E10D)" id="Polygon 1" />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <div className="flex-[1_0_0] h-0 min-h-px min-w-px relative">
        <div className="absolute inset-[-3.68px_-0.37%_-3.68px_0]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 134.503 7.36396">
            <path d={svgPaths.p24132e00} fill="var(--stroke-0, black)" id="Arrow 1" />
          </svg>
        </div>
      </div>
      <Paragraph4 />
    </div>
  );
}

function Frame6() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col gap-[16px] items-start relative w-full">
        <Frame5 />
        <Frame4 />
      </div>
    </div>
  );
}

function ClientCard() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame6 />
    </div>
  );
}

function Container19() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading7() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">Framer website</p>
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Radical Coffee</p>
    </div>
  );
}

function Container20() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading7 />
        <Paragraph5 />
      </div>
    </div>
  );
}

function Container18() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container19 />
      <Container20 />
    </div>
  );
}

function Paragraph6() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€2,250</p>
    </div>
  );
}

function Container22() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph6 />
      </div>
    </div>
  );
}

function Container21() {
  return (
    <div className="content-stretch flex h-[47.995px] items-center relative shrink-0" data-name="Container">
      <Container22 />
    </div>
  );
}

function Frame8() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container18 />
      <Container21 />
    </div>
  );
}

function Paragraph7() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">In progress</p>
    </div>
  );
}

function Paragraph8() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">23.01.2026</p>
    </div>
  );
}

function Frame9() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full">
      <Paragraph7 />
      <div className="flex items-center justify-center relative shrink-0 size-[16px]" style={{ "--transform-inner-width": "0", "--transform-inner-height": "18.875" } as React.CSSProperties}>
        <div className="flex-none rotate-[90deg]">
          <div className="relative size-[16px]">
            <div className="absolute bottom-1/4 left-[11.26%] right-[11.26%] top-[6.25%]">
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 12.3953 11">
                <path d={svgPaths.p310d0900} fill="var(--fill-0, #A5E10D)" id="Polygon 1" />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <div className="flex-[1_0_0] h-0 min-h-px min-w-px relative">
        <div className="absolute inset-[-3.68px_-0.29%_-3.68px_0]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 170.503 7.36396">
            <path d={svgPaths.p103e92c0} fill="var(--stroke-0, black)" id="Arrow 1" />
          </svg>
        </div>
      </div>
      <Paragraph8 />
    </div>
  );
}

function Frame7() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col gap-[16px] items-start relative w-full">
        <Frame8 />
        <Frame9 />
      </div>
    </div>
  );
}

function ClientCard1() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame7 />
    </div>
  );
}

function Container24() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">MD</p>
      </div>
    </div>
  );
}

function Heading8() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">Mindfull decoration</p>
    </div>
  );
}

function Paragraph9() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Mindfull decoration</p>
    </div>
  );
}

function Container25() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading8 />
        <Paragraph9 />
      </div>
    </div>
  );
}

function Container23() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container24 />
      <Container25 />
    </div>
  );
}

function Paragraph10() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€900</p>
    </div>
  );
}

function Container27() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph10 />
      </div>
    </div>
  );
}

function Container26() {
  return (
    <div className="content-stretch flex h-[47.995px] items-center relative shrink-0" data-name="Container">
      <Container27 />
    </div>
  );
}

function Frame11() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container23 />
      <Container26 />
    </div>
  );
}

function Paragraph11() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">Waiting for feedback</p>
    </div>
  );
}

function Paragraph12() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">23.01.2026</p>
    </div>
  );
}

function Frame12() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full">
      <Paragraph11 />
      <div className="flex items-center justify-center relative shrink-0 size-[16px]" style={{ "--transform-inner-width": "0", "--transform-inner-height": "18.875" } as React.CSSProperties}>
        <div className="flex-none rotate-[90deg]">
          <div className="relative size-[16px]">
            <div className="absolute bottom-1/4 left-[11.26%] right-[11.26%] top-[6.25%]">
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 12.3953 11">
                <path d={svgPaths.p310d0900} fill="var(--fill-0, #FF6900)" id="Polygon 1" />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <div className="flex-[1_0_0] h-0 min-h-px min-w-px relative">
        <div className="absolute inset-[-3.68px_-0.46%_-3.68px_0]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 109.503 7.36396">
            <path d={svgPaths.p1e33f800} fill="var(--stroke-0, black)" id="Arrow 1" />
          </svg>
        </div>
      </div>
      <Paragraph12 />
    </div>
  );
}

function Frame10() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col gap-[16px] items-start relative w-full">
        <Frame11 />
        <Frame12 />
      </div>
    </div>
  );
}

function ClientCard2() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame10 />
    </div>
  );
}

function Container11() {
  return (
    <div className="relative shrink-0 w-full" data-name="Container">
      <div className="content-stretch flex flex-col gap-[15.998px] items-start pb-0 pt-[32px] px-[15.998px] relative w-full">
        <Container12 />
        <ClientCard />
        <ClientCard1 />
        <ClientCard2 />
      </div>
    </div>
  );
}

function Heading9() {
  return (
    <div className="h-[27.995px] relative shrink-0 w-[63.932px]" data-name="Heading 2">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[20px] top-[-0.33px] tracking-[-0.4492px]">Clients</p>
      </div>
    </div>
  );
}

function Button5() {
  return (
    <div className="h-[23.993px] relative shrink-0 w-[29.74px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] left-[15.5px] not-italic text-[#00b8db] text-[16px] text-center top-[-0.78px] tracking-[-0.3125px] translate-x-[-50%]">Add</p>
      </div>
    </div>
  );
}

function Container29() {
  return (
    <div className="content-stretch flex h-[27.995px] items-center justify-between relative shrink-0 w-full" data-name="Container">
      <Heading9 />
      <Button5 />
    </div>
  );
}

function Button6() {
  return (
    <div className="bg-[#008236] h-[41.094px] relative rounded-[14px] shrink-0 w-[76.563px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] left-[38.5px] not-italic text-[16px] text-center text-white top-[7.77px] tracking-[-0.3125px] translate-x-[-50%]">✓ All</p>
      </div>
    </div>
  );
}

function Button7() {
  return (
    <div className="bg-white h-[41.094px] relative rounded-[14px] shrink-0 w-[138.307px]" data-name="Button">
      <div aria-hidden="true" className="absolute border-[#d1d5dc] border-[0.556px] border-solid inset-0 pointer-events-none rounded-[14px]" />
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] left-[70.06px] not-italic text-[#101828] text-[16px] text-center top-[7.77px] tracking-[-0.3125px] translate-x-[-50%]">First meeting</p>
      </div>
    </div>
  );
}

function Button8() {
  return (
    <div className="bg-white h-[41.094px] relative rounded-[14px] shrink-0 w-[165.842px]" data-name="Button">
      <div aria-hidden="true" className="absolute border-[#d1d5dc] border-[0.556px] border-solid inset-0 pointer-events-none rounded-[14px]" />
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] left-[83.06px] not-italic text-[#101828] text-[16px] text-center top-[7.77px] tracking-[-0.3125px] translate-x-[-50%]">Deposit received</p>
      </div>
    </div>
  );
}

function Container30() {
  return (
    <div className="content-stretch flex gap-[11.997px] h-[49.089px] items-start overflow-clip relative shrink-0 w-full" data-name="Container">
      <Button6 />
      <Button7 />
      <Button8 />
    </div>
  );
}

function Container33() {
  return (
    <div className="bg-[#434343] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[16px] text-white tracking-[-0.3125px]">NB</p>
      </div>
    </div>
  );
}

function Heading10() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Heading 3">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[18px] tracking-[-0.4395px]">NDA bank</p>
    </div>
  );
}

function Paragraph13() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#4a5565] text-[14px] tracking-[-0.1504px]">Retainer</p>
    </div>
  );
}

function Container34() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col h-full items-start relative">
        <Heading10 />
        <Paragraph13 />
      </div>
    </div>
  );
}

function Container32() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex gap-[15.998px] h-full items-center relative">
        <Container33 />
        <Container34 />
      </div>
    </div>
  );
}

function Paragraph14() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€3,500</p>
    </div>
  );
}

function Paragraph15() {
  return (
    <div className="absolute h-[20px] left-0 top-[27.99px] w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-[68.81px] not-italic text-[#4a5565] text-[14px] text-right top-[0.67px] tracking-[-0.1504px] translate-x-[-100%]">Salary</p>
    </div>
  );
}

function Container36() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph14 />
        <Paragraph15 />
      </div>
    </div>
  );
}

function Icon2() {
  return (
    <div className="h-[20px] overflow-clip relative shrink-0 w-full" data-name="Icon">
      <div className="absolute inset-[45.83%]" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
      <div className="absolute bottom-3/4 left-[45.83%] right-[45.83%] top-[16.67%]" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
      <div className="absolute bottom-[16.67%] left-[45.83%] right-[45.83%] top-3/4" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
    </div>
  );
}

function Button9() {
  return (
    <div className="relative shrink-0 size-[20px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Icon2 />
      </div>
    </div>
  );
}

function Container35() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[99.826px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex gap-[11.997px] items-center relative size-full">
        <Container36 />
        <Button9 />
      </div>
    </div>
  );
}

function ClientCard3() {
  return (
    <div className="bg-white h-[88.003px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-full" data-name="ClientCard">
      <div className="flex flex-row items-center size-full">
        <div className="content-stretch flex items-center justify-between px-[20px] py-0 relative size-full">
          <Container32 />
          <Container35 />
        </div>
      </div>
    </div>
  );
}

function Container38() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">MD</p>
      </div>
    </div>
  );
}

function Heading11() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Heading 3">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[18px] tracking-[-0.4395px]">Mindfull decoration</p>
    </div>
  );
}

function Paragraph16() {
  return (
    <div className="bg-[#232323] content-stretch flex items-center px-[6px] py-0 relative rounded-[5px] shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[14px] text-white tracking-[-0.1504px]">1</p>
    </div>
  );
}

function Paragraph17() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#4a5565] text-[14px] tracking-[-0.1504px]">Project</p>
    </div>
  );
}

function Frame13() {
  return (
    <div className="content-stretch flex gap-[8px] items-start relative shrink-0">
      <Paragraph16 />
      <Paragraph17 />
    </div>
  );
}

function Container39() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col h-full items-start relative">
        <Heading11 />
        <Frame13 />
      </div>
    </div>
  );
}

function Container37() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex gap-[15.998px] h-full items-center relative">
        <Container38 />
        <Container39 />
      </div>
    </div>
  );
}

function Paragraph18() {
  return (
    <div className="h-[27.995px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[78.58px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€900</p>
    </div>
  );
}

function Paragraph19() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-[79px] not-italic text-[#4a5565] text-[14px] text-right top-[0.67px] tracking-[-0.1504px] translate-x-[-100%]">Project total</p>
    </div>
  );
}

function Container41() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[78.394px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Paragraph18 />
        <Paragraph19 />
      </div>
    </div>
  );
}

function Icon3() {
  return (
    <div className="h-[20px] overflow-clip relative shrink-0 w-full" data-name="Icon">
      <div className="absolute inset-[45.83%]" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
      <div className="absolute bottom-3/4 left-[45.83%] right-[45.83%] top-[16.67%]" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
      <div className="absolute bottom-[16.67%] left-[45.83%] right-[45.83%] top-3/4" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
    </div>
  );
}

function Button10() {
  return (
    <div className="relative shrink-0 size-[20px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Icon3 />
      </div>
    </div>
  );
}

function Container40() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[110.391px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex gap-[11.997px] items-center relative size-full">
        <Container41 />
        <Button10 />
      </div>
    </div>
  );
}

function ClientCard4() {
  return (
    <div className="bg-white h-[88.003px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-full" data-name="ClientCard">
      <div className="flex flex-row items-center size-full">
        <div className="content-stretch flex items-center justify-between px-[20px] py-0 relative size-full">
          <Container37 />
          <Container40 />
        </div>
      </div>
    </div>
  );
}

function Container43() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading12() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Heading 3">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[18px] tracking-[-0.4395px]">Radical Coffee</p>
    </div>
  );
}

function Paragraph20() {
  return (
    <div className="bg-[#232323] content-stretch flex items-center px-[6px] py-0 relative rounded-[5px] shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[14px] text-white tracking-[-0.1504px]">3</p>
    </div>
  );
}

function Paragraph21() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#4a5565] text-[14px] tracking-[-0.1504px]">Projects</p>
    </div>
  );
}

function Frame14() {
  return (
    <div className="content-stretch flex gap-[8px] items-start relative shrink-0">
      <Paragraph20 />
      <Paragraph21 />
    </div>
  );
}

function Container44() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col h-full items-start relative">
        <Heading12 />
        <Frame14 />
      </div>
    </div>
  );
}

function Container42() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex gap-[15.998px] h-full items-center relative">
        <Container43 />
        <Container44 />
      </div>
    </div>
  );
}

function Paragraph22() {
  return (
    <div className="h-[27.995px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[78.58px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€3000</p>
    </div>
  );
}

function Paragraph23() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-[79px] not-italic text-[#4a5565] text-[14px] text-right top-[0.67px] tracking-[-0.1504px] translate-x-[-100%]">Project total</p>
    </div>
  );
}

function Container46() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[78.394px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Paragraph22 />
        <Paragraph23 />
      </div>
    </div>
  );
}

function Icon4() {
  return (
    <div className="h-[20px] overflow-clip relative shrink-0 w-full" data-name="Icon">
      <div className="absolute inset-[45.83%]" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
      <div className="absolute bottom-3/4 left-[45.83%] right-[45.83%] top-[16.67%]" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
      <div className="absolute bottom-[16.67%] left-[45.83%] right-[45.83%] top-3/4" data-name="Vector">
        <div className="absolute inset-[-50%]">
          <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 3.33333 3.33333">
            <path d={svgPaths.p3815c300} id="Vector" stroke="var(--stroke-0, #99A1AF)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.66667" />
          </svg>
        </div>
      </div>
    </div>
  );
}

function Button11() {
  return (
    <div className="relative shrink-0 size-[20px]" data-name="Button">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Icon4 />
      </div>
    </div>
  );
}

function Container45() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[110.391px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex gap-[11.997px] items-center relative size-full">
        <Container46 />
        <Button11 />
      </div>
    </div>
  );
}

function ClientCard5() {
  return (
    <div className="bg-white h-[88.003px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-full" data-name="ClientCard">
      <div className="flex flex-row items-center size-full">
        <div className="content-stretch flex items-center justify-between px-[20px] py-0 relative size-full">
          <Container42 />
          <Container45 />
        </div>
      </div>
    </div>
  );
}

function Container31() {
  return (
    <div className="content-stretch flex flex-col gap-[15.998px] items-start relative shrink-0 w-full" data-name="Container">
      <ClientCard3 />
      <ClientCard4 />
      <ClientCard5 />
    </div>
  );
}

function Container28() {
  return (
    <div className="content-stretch flex flex-col gap-[15.998px] items-start pb-0 pt-[32px] px-[15.998px] relative shrink-0 w-[440px]" data-name="Container">
      <Container29 />
      <Container30 />
      <Container31 />
    </div>
  );
}

function App() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[16px] pt-0 px-0 relative shrink-0 w-full" data-name="App">
      <StatusBarIPhone />
      <Frame2 />
      <Container2 />
      <Frame1 />
      <Container11 />
      <Container28 />
    </div>
  );
}

function HomeIndicator() {
  return (
    <div className="h-[34px] relative shrink-0 w-[440px]" data-name="Home Indicator">
      <div className="absolute bottom-[8px] flex h-[5px] items-center justify-center left-1/2 translate-x-[-50%] w-[144px]">
        <div className="flex-none rotate-[180deg] scale-y-[-100%]">
          <div className="bg-black h-[5px] rounded-[100px] w-[144px]" data-name="Home Indicator" />
        </div>
      </div>
    </div>
  );
}

function Icon5() {
  return (
    <div className="relative shrink-0 size-[27.995px]" data-name="Icon">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 27.9948 27.9948">
        <g id="Icon">
          <path d="M5.83229 13.9974H22.1626" id="Vector" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.3329" />
          <path d="M13.9974 5.83223V22.1625" id="Vector_2" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.3329" />
        </g>
      </svg>
    </div>
  );
}

function App1() {
  return (
    <div className="absolute bg-[#00b8db] content-stretch flex items-center justify-center left-[371px] rounded-[18641400px] shadow-[0px_10px_15px_-3px_rgba(0,0,0,0.1),0px_4px_6px_-4px_rgba(0,0,0,0.1)] size-[55.998px] top-[1292.87px]" data-name="App">
      <Icon5 />
    </div>
  );
}

function Frame3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[440px]">
      <App />
      <HomeIndicator />
      <App1 />
    </div>
  );
}

export default function Dashboard() {
  return (
    <div className="bg-[#f0f0f0] content-stretch flex items-start overflow-clip relative rounded-[44px] size-full" data-name="Dashboard">
      <Frame3 />
    </div>
  );
}