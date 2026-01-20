import React from 'react';
import { useCRM } from './crm-context';
import { Search, Plus } from 'lucide-react';

type DashboardScreenProps = {
  onNavigate: (screen: string, data?: any) => void;
};

export function DashboardScreen({ onNavigate }: DashboardScreenProps) {
  const { clients, projects, events } = useCRM();
  const [timeFilter, setTimeFilter] = React.useState<'week' | 'month'>('week');

  const activeProjects = projects.filter(p => p.status === 'in progress').length;
  const inProgressAmount = projects
    .filter(p => p.status === 'in progress')
    .reduce((sum, p) => sum + p.amount, 0);
  const deadlines = projects.filter(p => new Date(p.deadline) > new Date()).length;

  return (
    <>
      {/* Header */}
      <div className="content-stretch flex items-center justify-between pb-0 pt-[16px] px-0 relative shrink-0 w-full">
        <div className="flex-[1_0_0] h-[48px] min-h-px min-w-px relative">
          <div className="flex flex-col justify-center size-full">
            <div className="content-stretch flex flex-col items-start justify-center px-[15.998px] py-0 relative size-full">
              <p className="font-['Inter',sans-serif] font-semibold leading-[36px] text-[#101828] text-[30px] tracking-[0.3955px]">
                Hi Basil
              </p>
            </div>
          </div>
        </div>
        <div className="content-stretch flex items-center gap-2 px-[16px] py-0 relative shrink-0">
          <button className="bg-white relative rounded-[16px] shrink-0 size-[48px] flex items-center justify-center">
            <Search className="size-6 text-[#4A5565]" />
          </button>
        </div>
      </div>

      {/* Situation Filters */}
      <div className="relative shrink-0 w-full px-[16px] py-[16px]">
        <div className="flex gap-2 items-center">
          <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[16px]">Situation</p>
          <button
            onClick={() => setTimeFilter('week')}
            className={`px-4 py-2 rounded-full text-[14px] font-medium transition-colors ${
              timeFilter === 'week'
                ? 'bg-[#00a63e] text-white'
                : 'bg-white text-[#4A5565]'
            }`}
          >
            This week
          </button>
          <button
            onClick={() => setTimeFilter('month')}
            className={`px-4 py-2 rounded-full text-[14px] font-medium transition-colors ${
              timeFilter === 'month'
                ? 'bg-[#00a63e] text-white'
                : 'bg-white text-[#4A5565]'
            }`}
          >
            This month
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="relative shrink-0 w-full">
        <div className="grid grid-cols-2 gap-[16px] px-[16px]">
          <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(224, 242, 254) 0%, rgb(186, 230, 253) 100%)" }}>
            <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">Active projects</p>
            <p className="font-['Inter',sans-serif] font-semibold text-[#0369a1] text-[36px] mt-1">{activeProjects}</p>
          </div>
          <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(240, 245, 224) 63.427%, rgb(150, 202, 73) 171.02%)" }}>
            <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">In progress</p>
            <p className="font-['Inter',sans-serif] font-semibold text-[#00a63e] text-[36px] mt-1">€{inProgressAmount.toLocaleString()}</p>
          </div>
          <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(254, 243, 199) 0%, rgb(253, 224, 71) 100%)" }}>
            <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">Deadlines</p>
            <p className="font-['Inter',sans-serif] font-semibold text-[#ca8a04] text-[36px] mt-1">{deadlines}</p>
          </div>
          <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(255, 255, 255) 63.427%, rgb(192, 192, 192) 171.02%)" }}>
            <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">Payments</p>
            <p className="font-['Inter',sans-serif] font-semibold text-[#0f0e0e] text-[36px] mt-1">€0</p>
          </div>
        </div>
      </div>

      {/* Events */}
      <div className="relative shrink-0 w-full mt-[32px]">
        <div className="flex flex-col gap-[15.998px] px-[15.998px]">
          <div className="flex items-center justify-between">
            <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px]">Events</p>
            <button className="font-['Inter',sans-serif] font-medium text-[#00a63e] text-[14px]">View all</button>
          </div>
          {events.slice(0, 3).map(event => (
            <div
              key={event.id}
              onClick={() => onNavigate('client', { clientId: event.clientId })}
              className="bg-white rounded-[16px] shadow-sm p-[16px] flex items-center justify-between cursor-pointer active:scale-[0.98] transition-transform"
            >
              <div className="flex items-center gap-3">
                <div className="bg-[#e5e5e5] rounded-full size-[48px] flex items-center justify-center">
                  <p className="font-['Inter',sans-serif] font-semibold text-[#232323] text-[16px]">
                    {event.clientName.slice(0, 2).toUpperCase()}
                  </p>
                </div>
                <div>
                  <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">{event.clientName}</p>
                  <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px]">{event.label}</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">€{event.amount.toLocaleString()}</p>
                <p className="font-['Inter',sans-serif] font-normal text-[14px]" style={{ color: event.statusColor }}>{event.status}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Clients */}
      <div className="relative shrink-0 w-full mt-[32px] pb-[32px]">
        <div className="flex flex-col gap-[15.998px] px-[15.998px]">
          <div className="flex items-center justify-between">
            <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px]">Clients</p>
            <button
              onClick={() => onNavigate('add-client')}
              className="font-['Inter',sans-serif] font-medium text-[#00a63e] text-[14px]"
            >
              Add
            </button>
          </div>

          {/* Filter Tabs */}
          <div className="flex gap-2">
            <button className="bg-[#00a63e] text-white px-4 py-2 rounded-full text-[14px] font-medium">
              All
            </button>
            <button className="bg-white text-[#4a5565] px-4 py-2 rounded-full text-[14px] font-medium">
              First meeting
            </button>
            <button className="bg-white text-[#4a5565] px-4 py-2 rounded-full text-[14px] font-medium">
              Deposit received
            </button>
          </div>

          {clients.map(client => (
            <div
              key={client.id}
              onClick={() => onNavigate('client', { clientId: client.id })}
              className="bg-white rounded-[16px] shadow-sm p-[16px] flex items-center justify-between cursor-pointer active:scale-[0.98] transition-transform"
            >
              <div className="flex items-center gap-3">
                <div
                  className="rounded-full size-[48px] flex items-center justify-center"
                  style={{ backgroundColor: client.color }}
                >
                  <p className="font-['Inter',sans-serif] font-semibold text-white text-[16px]">
                    {client.initials}
                  </p>
                </div>
                <div>
                  <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">{client.name}</p>
                  <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px] capitalize">{client.type}</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">
                  €{(client.salary || client.totalAmount || 0).toLocaleString()}
                </p>
                <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px]">
                  {client.type === 'retainer' ? 'Salary' : 'Project total'}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Floating Action Button */}
      <button
        onClick={() => onNavigate('add-client')}
        className="fixed bottom-[80px] right-[32px] bg-[#00a63e] rounded-full size-[56px] flex items-center justify-center shadow-lg active:scale-95 transition-transform"
      >
        <Plus className="size-6 text-white" strokeWidth={3} />
      </button>
    </>
  );
}