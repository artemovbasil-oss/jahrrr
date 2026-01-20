import React, { useState } from 'react';
import { useCRM, Client } from './crm-context';
import { ChevronLeft, MoreVertical, Edit, Copy, Archive } from 'lucide-react';

type ClientDetailScreenProps = {
  clientId: string;
  onNavigate: (screen: string, data?: any) => void;
};

export function ClientDetailScreen({ clientId, onNavigate }: ClientDetailScreenProps) {
  const { getClient, getClientProjects, addClient, updateClient } = useCRM();
  const [showMenu, setShowMenu] = useState(false);
  const client = getClient(clientId);
  const projects = getClientProjects(clientId);

  if (!client) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <p className="text-[#4a5565] text-[16px]">Client not found</p>
      </div>
    );
  }

  const isRetainer = client.type === 'retainer';

  const handleDuplicate = () => {
    const duplicatedClient = {
      ...client,
      name: `${client.name} (Copy)`,
      payments: 0,
      inProgress: 0,
    };
    delete (duplicatedClient as any).id;
    addClient(duplicatedClient);
    setShowMenu(false);
  };

  const handleArchive = () => {
    // In a real app, you'd have an archived status
    updateClient(clientId, { ...client });
    setShowMenu(false);
    onNavigate('dashboard');
  };

  return (
    <>
      {/* Header */}
      <div className="content-stretch flex items-center justify-between pb-0 pt-[16px] px-0 relative shrink-0 w-full">
        <div className="flex-[1_0_0] h-[48px] min-h-px min-w-px relative">
          <div className="flex flex-col justify-center size-full">
            <div className="content-stretch flex gap-[16px] h-[35.998px] items-center px-[15.998px] py-0 relative w-full">
              <button
                onClick={() => onNavigate('dashboard')}
                className="flex h-[20px] items-center justify-center relative shrink-0 w-[14px]"
              >
                <ChevronLeft className="size-6 text-[#4A5565]" strokeWidth={2} />
              </button>
              <p className="flex-[1_0_0] font-['Inter',sans-serif] font-semibold leading-[36px] min-h-px min-w-px text-[#101828] text-[30px] overflow-hidden text-ellipsis tracking-[0.3955px]">
                {client.name}
              </p>
            </div>
          </div>
        </div>
        <div className="content-stretch flex items-center gap-2 px-[16px] py-0 relative shrink-0">
          {isRetainer && (
            <div className="bg-[#434343] px-[8px] py-[6px] rounded-[14px]">
              <p className="font-['Inter',sans-serif] font-medium text-white text-[16px]">Retainer</p>
            </div>
          )}
          {!isRetainer && (
            <div className="bg-[#434343] px-[8px] py-[6px] rounded-[14px]">
              <p className="font-['Inter',sans-serif] font-medium text-white text-[16px]">Contract</p>
            </div>
          )}
          <div className="relative">
            <button 
              onClick={() => setShowMenu(!showMenu)}
              className="bg-white relative rounded-[16px] shrink-0 size-[48px] flex items-center justify-center"
            >
              <MoreVertical className="size-6 text-[#4A5565]" />
            </button>
            
            {/* Settings Menu */}
            {showMenu && (
              <>
                <div 
                  className="fixed inset-0 z-40" 
                  onClick={() => setShowMenu(false)}
                />
                <div className="absolute right-0 top-[56px] bg-white rounded-[16px] shadow-xl z-50 overflow-hidden min-w-[200px] animate-in fade-in slide-in-from-top-2 duration-200">
                  <button
                    onClick={() => {
                      setShowMenu(false);
                      onNavigate('edit-client', { clientId });
                    }}
                    className="w-full px-4 py-3 flex items-center gap-3 hover:bg-gray-50 transition-colors"
                  >
                    <Edit className="size-5 text-[#4A5565]" />
                    <span className="font-['Inter',sans-serif] font-medium text-[#101828] text-[15px]">Modify</span>
                  </button>
                  <button
                    onClick={handleDuplicate}
                    className="w-full px-4 py-3 flex items-center gap-3 hover:bg-gray-50 transition-colors border-t border-gray-100"
                  >
                    <Copy className="size-5 text-[#4A5565]" />
                    <span className="font-['Inter',sans-serif] font-medium text-[#101828] text-[15px]">Duplicate</span>
                  </button>
                  <button
                    onClick={handleArchive}
                    className="w-full px-4 py-3 flex items-center gap-3 hover:bg-gray-50 transition-colors border-t border-gray-100"
                  >
                    <Archive className="size-5 text-[#4A5565]" />
                    <span className="font-['Inter',sans-serif] font-medium text-[#101828] text-[15px]">Archive</span>
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="relative shrink-0 w-full pt-[32px]">
        <div className="grid grid-cols-2 gap-[16px] px-[16px]">
          {isRetainer ? (
            <>
              <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(240, 245, 224) 63.427%, rgb(150, 202, 73) 171.02%)" }}>
                <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">Salary</p>
                <p className="font-['Inter',sans-serif] font-semibold text-[#00a63e] text-[36px] mt-1">€{client.salary?.toLocaleString()}</p>
              </div>
              <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(255, 255, 255) 63.427%, rgb(192, 192, 192) 171.02%)" }}>
                <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">Payments</p>
                <p className="font-['Inter',sans-serif] font-semibold text-[#0f0e0e] text-[36px] mt-1">€{client.payments?.toLocaleString()}</p>
              </div>
            </>
          ) : (
            <>
              <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(240, 245, 224) 63.427%, rgb(150, 202, 73) 171.02%)" }}>
                <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">In progress</p>
                <p className="font-['Inter',sans-serif] font-semibold text-[#00a63e] text-[36px] mt-1">€{client.inProgress?.toLocaleString()}</p>
              </div>
              <div className="rounded-[24px] shadow-sm p-[20px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(255, 255, 255) 63.427%, rgb(192, 192, 192) 171.02%)" }}>
                <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[18px]">Payments</p>
                <p className="font-['Inter',sans-serif] font-semibold text-[#0f0e0e] text-[36px] mt-1">€0</p>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Projects Section (if not retainer) */}
      {!isRetainer && projects.length > 0 && (
        <div className="relative shrink-0 w-full mt-[32px]">
          <div className="flex flex-col gap-[15.998px] px-[15.998px]">
            <div className="flex items-center justify-between">
              <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px]">Projects</p>
              <button className="bg-[#232323] text-white px-3 py-1 rounded-full text-[12px] font-medium flex items-center gap-1">
                <span className="bg-white text-[#232323] rounded-full w-5 h-5 flex items-center justify-center text-[11px] font-bold">
                  {projects.length}
                </span>
                Projects
              </button>
            </div>
            {projects.map(project => (
              <div
                key={project.id}
                onClick={() => onNavigate('project', { projectId: project.id })}
                className="bg-white rounded-[16px] shadow-sm p-[16px] cursor-pointer active:scale-[0.98] transition-transform"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="bg-[#e5e5e5] rounded-full size-[40px] flex items-center justify-center">
                      <p className="font-['Inter',sans-serif] font-semibold text-[#232323] text-[14px]">
                        {client.initials}
                      </p>
                    </div>
                    <div>
                      <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">{project.name}</p>
                      <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px]">{client.name}</p>
                    </div>
                  </div>
                  <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">€{project.amount.toLocaleString()}</p>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="capitalize text-[#4a5565] text-[14px]">{project.status}</span>
                    <div className="size-2 rounded-full bg-[#f4a526]" />
                  </div>
                  <p className="text-[#4a5565] text-[14px]">{new Date(project.deadline).toLocaleDateString()}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Contacts Section */}
      <div className="relative shrink-0 w-full mt-[32px] pb-[32px]">
        <div className="flex flex-col gap-[15.998px] px-[15.998px]">
          <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px]">Contacts</p>
          {client.contacts.map(contact => (
            <div key={contact.id} className="bg-white rounded-[16px] shadow-sm p-[16px] flex items-center gap-3">
              <div
                className="rounded-full size-[48px] flex items-center justify-center shrink-0"
                style={{
                  backgroundColor: contact.type === 'name' ? client.color : '#e5e5e5',
                }}
              >
                <p className="font-['Inter',sans-serif] font-semibold text-[16px]" style={{ color: contact.type === 'name' ? 'white' : '#232323' }}>
                  {contact.type === 'name' ? client.initials : client.initials}
                </p>
              </div>
              <div className="flex-1 min-w-0">
                {contact.type === 'name' ? (
                  <>
                    <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[18px]">{contact.value}</p>
                    {contact.role && (
                      <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px]">{contact.role}</p>
                    )}
                  </>
                ) : (
                  <>
                    <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[18px]">{contact.value}</p>
                    {contact.isPreferred && (
                      <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px]">Preferred contact</p>
                    )}
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}