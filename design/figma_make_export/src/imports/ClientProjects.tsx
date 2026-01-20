import svgPaths from "./svg-3u16twdj5u";

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
    <div className="content-stretch flex gap-[16px] h-[35.998px] items-center relative shrink-0 w-full" data-name="Heading 1">
      <div className="flex h-[20px] items-center justify-center relative shrink-0 w-[14px]" style={{ "--transform-inner-width": "0", "--transform-inner-height": "18.875" } as React.CSSProperties}>
        <div className="flex-none rotate-[270deg]">
          <div className="h-[14px] relative w-[20px]">
            <div className="absolute inset-[-7.14%_-5%]">
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 21.9996 15.9995">
                <path d={svgPaths.p39dac180} id="Polygon 2" stroke="var(--stroke-0, #4A5565)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.99942" />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[36px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[30px] text-ellipsis tracking-[0.3955px]">Radical Coffeee</p>
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

function Button() {
  return (
    <div className="bg-[#e5e5e5] content-stretch flex items-center justify-center px-[8px] py-[6px] relative rounded-[14px] shrink-0" data-name="Button">
      <p className="css-ew64yg font-['Inter:Medium',sans-serif] font-medium leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] text-center tracking-[-0.3125px]">Contract</p>
    </div>
  );
}

function Frame7() {
  return (
    <div className="content-stretch flex flex-[1_0_0] items-center min-h-px min-w-px relative">
      <Container />
      <Button />
    </div>
  );
}

function Icon() {
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
        <Icon />
      </div>
    </div>
  );
}

function Container1() {
  return (
    <div className="content-stretch flex items-center px-[16px] py-0 relative shrink-0" data-name="Container">
      <Button1 />
    </div>
  );
}

function Frame3() {
  return (
    <div className="content-stretch flex items-center justify-between pb-0 pt-[16px] px-0 relative shrink-0 w-full">
      <Frame7 />
      <Container1 />
    </div>
  );
}

function Heading2() {
  return (
    <div className="content-stretch flex items-center relative shrink-0 w-full" data-name="Heading 3">
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Medium',sans-serif] font-medium leading-[27px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[18px] text-ellipsis tracking-[-0.4395px]">In progress</p>
    </div>
  );
}

function Container3() {
  return (
    <div className="h-[39.991px] relative shrink-0 w-full" data-name="Container">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[40px] left-0 not-italic text-[#00a63e] text-[36px] top-[0.33px] tracking-[0.3691px]">€1,280</p>
    </div>
  );
}

function StatsCard() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative rounded-[24px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0)]" data-name="StatsCard" style={{ backgroundImage: "linear-gradient(135deg, rgb(240, 245, 224) 63.427%, rgb(150, 202, 73) 171.02%)" }}>
      <div className="content-stretch flex flex-col gap-[3.993px] items-start px-[23.993px] py-[20px] relative w-full">
        <Heading2 />
        <Container3 />
      </div>
    </div>
  );
}

function Heading3() {
  return (
    <div className="content-stretch flex items-center relative shrink-0 w-full" data-name="Heading 3">
      <p className="css-g0mm18 flex-[1_0_0] font-['Inter:Medium',sans-serif] font-medium leading-[27px] min-h-px min-w-px not-italic overflow-hidden relative text-[#101828] text-[18px] text-ellipsis tracking-[-0.4395px]">Payments</p>
    </div>
  );
}

function Container4() {
  return (
    <div className="h-[39.991px] relative shrink-0 w-full" data-name="Container">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[40px] left-0 not-italic text-[#0f0e0e] text-[36px] top-[0.33px] tracking-[0.3691px]">€0</p>
    </div>
  );
}

function StatsCard1() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative rounded-[24px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0)]" data-name="StatsCard" style={{ backgroundImage: "linear-gradient(135deg, rgb(255, 255, 255) 63.427%, rgb(192, 192, 192) 171.02%)" }}>
      <div className="content-stretch flex flex-col gap-[3.993px] items-start px-[23.993px] py-[20px] relative w-full">
        <Heading3 />
        <Container4 />
      </div>
    </div>
  );
}

function Container2() {
  return (
    <div className="relative shrink-0 w-full" data-name="Container">
      <div className="content-start flex flex-wrap gap-[15px_16px] items-start pb-0 pt-[32px] px-[16px] relative w-full">
        <StatsCard />
        <StatsCard1 />
      </div>
    </div>
  );
}

function Frame1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full">
      <Container2 />
    </div>
  );
}

function Paragraph() {
  return (
    <div className="bg-[#232323] content-stretch flex items-center px-[6px] py-0 relative rounded-[5px] shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[14px] text-white tracking-[-0.1504px]">3</p>
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#4a5565] text-[14px] tracking-[-0.1504px]">Projects</p>
    </div>
  );
}

function Frame6() {
  return (
    <div className="content-stretch flex gap-[8px] items-start relative shrink-0">
      <Paragraph />
      <Paragraph1 />
    </div>
  );
}

function Heading1() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative" data-name="Heading 2">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-between relative w-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[20px] tracking-[-0.4492px]">Projects</p>
        <Frame6 />
      </div>
    </div>
  );
}

function Container6() {
  return (
    <div className="content-stretch flex h-[27.995px] items-center justify-between relative shrink-0 w-full" data-name="Container">
      <Heading1 />
    </div>
  );
}

function Container8() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading4() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">Framer website</p>
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Radical Coffee</p>
    </div>
  );
}

function Container9() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading4 />
        <Paragraph2 />
      </div>
    </div>
  );
}

function Container7() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container8 />
      <Container9 />
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€2,250</p>
    </div>
  );
}

function Container11() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph3 />
      </div>
    </div>
  );
}

function Container10() {
  return (
    <div className="content-stretch flex h-[47.995px] items-center relative shrink-0" data-name="Container">
      <Container11 />
    </div>
  );
}

function Frame4() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container7 />
      <Container10 />
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">In progress</p>
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">23.01.2026</p>
    </div>
  );
}

function Frame8() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full">
      <Paragraph4 />
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
      <Paragraph5 />
    </div>
  );
}

function Frame5() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col gap-[16px] items-start relative w-full">
        <Frame4 />
        <Frame8 />
      </div>
    </div>
  );
}

function ClientCard() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame5 />
    </div>
  );
}

function Container13() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading5() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">Presentation design</p>
    </div>
  );
}

function Paragraph6() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Radical Coffee</p>
    </div>
  );
}

function Container14() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading5 />
        <Paragraph6 />
      </div>
    </div>
  );
}

function Container12() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container13 />
      <Container14 />
    </div>
  );
}

function Paragraph7() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€1,000</p>
    </div>
  );
}

function Container16() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph7 />
      </div>
    </div>
  );
}

function Container15() {
  return (
    <div className="content-stretch flex h-[47.995px] items-center relative shrink-0" data-name="Container">
      <Container16 />
    </div>
  );
}

function Frame10() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container12 />
      <Container15 />
    </div>
  );
}

function Paragraph8() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">In progress</p>
    </div>
  );
}

function Paragraph9() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">23.01.2026</p>
    </div>
  );
}

function Frame11() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full">
      <Paragraph8 />
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
      <Paragraph9 />
    </div>
  );
}

function Frame9() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col gap-[16px] items-start relative w-full">
        <Frame10 />
        <Frame11 />
      </div>
    </div>
  );
}

function ClientCard1() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame9 />
    </div>
  );
}

function Container18() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading6() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">Branding</p>
    </div>
  );
}

function Paragraph10() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Radical Coffee</p>
    </div>
  );
}

function Container19() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading6 />
        <Paragraph10 />
      </div>
    </div>
  );
}

function Container17() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container18 />
      <Container19 />
    </div>
  );
}

function Paragraph11() {
  return (
    <div className="absolute h-[27.995px] left-0 top-0 w-[67.83px]" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-[68px] not-italic text-[#101828] text-[20px] text-right top-[-0.33px] tracking-[-0.4492px] translate-x-[-100%]">€1,000</p>
    </div>
  );
}

function Container21() {
  return (
    <div className="h-[47.995px] relative shrink-0 w-[67.83px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <Paragraph11 />
      </div>
    </div>
  );
}

function Container20() {
  return (
    <div className="content-stretch flex h-[47.995px] items-center relative shrink-0" data-name="Container">
      <Container21 />
    </div>
  );
}

function Frame13() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container17 />
      <Container20 />
    </div>
  );
}

function Paragraph12() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">In progress</p>
    </div>
  );
}

function Paragraph13() {
  return (
    <div className="content-stretch flex items-center justify-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#101828] text-[14px] tracking-[-0.1504px]">23.01.2026</p>
    </div>
  );
}

function Frame14() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full">
      <Paragraph12 />
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
      <Paragraph13 />
    </div>
  );
}

function Frame12() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col gap-[16px] items-start relative w-full">
        <Frame13 />
        <Frame14 />
      </div>
    </div>
  );
}

function ClientCard2() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame12 />
    </div>
  );
}

function Container5() {
  return (
    <div className="relative shrink-0 w-full" data-name="Container">
      <div className="content-stretch flex flex-col gap-[15.998px] items-start pb-0 pt-[32px] px-[15.998px] relative w-full">
        <Container6 />
        <ClientCard />
        <ClientCard1 />
        <ClientCard2 />
      </div>
    </div>
  );
}

function Heading7() {
  return (
    <div className="h-[27.995px] relative shrink-0 w-[212.049px]" data-name="Heading 2">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid relative size-full">
        <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[20px] top-[-0.33px] tracking-[-0.4492px]">Contacts</p>
      </div>
    </div>
  );
}

function Container23() {
  return (
    <div className="content-stretch flex h-[27.995px] items-center justify-between relative shrink-0 w-full" data-name="Container">
      <Heading7 />
    </div>
  );
}

function Container25() {
  return (
    <div className="bg-[#77afca] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[16px] text-white tracking-[-0.3125px]">IB</p>
      </div>
    </div>
  );
}

function Heading8() {
  return (
    <div className="h-[28.003px] relative shrink-0 w-full" data-name="Heading 3">
      <p className="absolute css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] left-0 not-italic text-[#101828] text-[18px] top-[0.33px] tracking-[-0.4395px]">Ian Burgerson</p>
    </div>
  );
}

function Paragraph14() {
  return (
    <div className="h-[20px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="absolute css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] left-0 not-italic text-[#4a5565] text-[14px] top-[0.67px] tracking-[-0.1504px]">Head of Design</p>
    </div>
  );
}

function Container26() {
  return (
    <div className="h-[48.003px] relative shrink-0 w-[83.533px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative size-full">
        <Heading8 />
        <Paragraph14 />
      </div>
    </div>
  );
}

function Container24() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0 w-[147.526px]" data-name="Container">
      <Container25 />
      <Container26 />
    </div>
  );
}

function Frame16() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container24 />
    </div>
  );
}

function Frame15() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative w-full">
        <Frame16 />
      </div>
    </div>
  );
}

function ClientCard3() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame15 />
    </div>
  );
}

function Container28() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading9() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Heading 3">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[18px] tracking-[-0.4395px]">+90 554 019 6137</p>
    </div>
  );
}

function Paragraph15() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Paragraph">
      <p className="css-ew64yg font-['Inter:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#4a5565] text-[14px] tracking-[-0.1504px]">Preffered contact</p>
    </div>
  );
}

function Container29() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col h-full items-start relative">
        <Heading9 />
        <Paragraph15 />
      </div>
    </div>
  );
}

function Container27() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0" data-name="Container">
      <Container28 />
      <Container29 />
    </div>
  );
}

function Frame18() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container27 />
    </div>
  );
}

function Frame17() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative w-full">
        <Frame18 />
      </div>
    </div>
  );
}

function ClientCard4() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame17 />
    </div>
  );
}

function Container31() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading10() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Heading 3">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[18px] tracking-[-0.4395px]">i.burgerson@radicalcoffee.com</p>
    </div>
  );
}

function Container32() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col h-full items-start justify-center relative">
        <Heading10 />
      </div>
    </div>
  );
}

function Container30() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0" data-name="Container">
      <Container31 />
      <Container32 />
    </div>
  );
}

function Frame20() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container30 />
    </div>
  );
}

function Frame19() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative w-full">
        <Frame20 />
      </div>
    </div>
  );
}

function ClientCard5() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame19 />
    </div>
  );
}

function Container34() {
  return (
    <div className="bg-[#e5e5e5] relative rounded-[18641400px] shrink-0 size-[47.995px]" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex items-center justify-center relative size-full">
        <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[24px] not-italic relative shrink-0 text-[#232323] text-[16px] tracking-[-0.3125px]">RC</p>
      </div>
    </div>
  );
}

function Heading11() {
  return (
    <div className="content-stretch flex items-center relative shrink-0" data-name="Heading 3">
      <p className="css-ew64yg font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[28px] not-italic relative shrink-0 text-[#101828] text-[18px] tracking-[-0.4395px]">@iburgerson</p>
    </div>
  );
}

function Container35() {
  return (
    <div className="h-[48.003px] relative shrink-0" data-name="Container">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col h-full items-start justify-center relative">
        <Heading11 />
      </div>
    </div>
  );
}

function Container33() {
  return (
    <div className="content-stretch flex gap-[15.998px] h-[48.003px] items-center relative shrink-0" data-name="Container">
      <Container34 />
      <Container35 />
    </div>
  );
}

function Frame22() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[368.003px]">
      <Container33 />
    </div>
  );
}

function Frame21() {
  return (
    <div className="flex-[1_0_0] min-h-px min-w-px relative">
      <div className="bg-clip-padding border-0 border-[transparent] border-solid content-stretch flex flex-col items-start relative w-full">
        <Frame22 />
      </div>
    </div>
  );
}

function ClientCard6() {
  return (
    <div className="bg-white content-stretch flex items-center justify-between px-[20px] py-[16px] relative rounded-[16px] shadow-[0px_1px_3px_0px_rgba(0,0,0,0.1),0px_1px_2px_-1px_rgba(0,0,0,0.1)] shrink-0 w-[408.003px]" data-name="ClientCard">
      <Frame21 />
    </div>
  );
}

function Container22() {
  return (
    <div className="relative shrink-0 w-full" data-name="Container">
      <div className="content-stretch flex flex-col gap-[15.998px] items-start pb-0 pt-[32px] px-[15.998px] relative w-full">
        <Container23 />
        <ClientCard3 />
        <ClientCard4 />
        <ClientCard5 />
        <ClientCard6 />
      </div>
    </div>
  );
}

function App() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[16px] pt-0 px-0 relative shrink-0 w-full" data-name="App">
      <StatusBarIPhone />
      <Frame3 />
      <Frame1 />
      <Container5 />
      <Container22 />
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

function Frame2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[440px]">
      <App />
      <HomeIndicator />
    </div>
  );
}

export default function ClientProjects() {
  return (
    <div className="bg-[#f0f0f0] content-stretch flex items-start overflow-clip relative rounded-[44px] size-full" data-name="Client — projects">
      <Frame2 />
    </div>
  );
}