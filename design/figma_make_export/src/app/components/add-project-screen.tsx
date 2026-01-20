import React, { useState } from 'react';
import { useCRM, Project } from './crm-context';
import { ChevronLeft } from 'lucide-react';

type AddProjectScreenProps = {
  clientId?: string;
  onNavigate: (screen: string, data?: any) => void;
};

export function AddProjectScreen({ clientId, onNavigate }: AddProjectScreenProps) {
  const { clients, addProject } = useCRM();
  const [formData, setFormData] = useState({
    clientId: clientId || '',
    name: '',
    amount: '',
    status: 'in progress' as Project['status'],
    deadline: new Date().toISOString().split('T')[0],
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.name || !formData.clientId || !formData.amount) return;

    const newProject: Omit<Project, 'id'> = {
      clientId: formData.clientId,
      name: formData.name,
      amount: parseFloat(formData.amount),
      status: formData.status,
      deadline: formData.deadline,
    };

    addProject(newProject);
    onNavigate('client', { clientId: formData.clientId });
  };

  const selectedClient = clients.find(c => c.id === formData.clientId);

  return (
    <>
      {/* Header */}
      <div className="content-stretch flex items-center justify-between pb-0 pt-[16px] px-0 relative shrink-0 w-full">
        <div className="flex-[1_0_0] h-[48px] min-h-px min-w-px relative">
          <div className="flex flex-col justify-center size-full">
            <div className="content-stretch flex gap-[16px] h-[35.998px] items-center px-[15.998px] py-0 relative w-full">
              <button
                onClick={() => onNavigate(clientId ? 'client' : 'dashboard', clientId ? { clientId } : undefined)}
                className="flex h-[20px] items-center justify-center relative shrink-0 w-[14px]"
              >
                <ChevronLeft className="size-6 text-[#4A5565]" strokeWidth={2} />
              </button>
              <p className="flex-[1_0_0] font-['Inter',sans-serif] font-semibold leading-[36px] min-h-px min-w-px text-[#101828] text-[30px] overflow-hidden text-ellipsis tracking-[0.3955px]">
                New Project
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto px-[16px] pt-[32px] pb-[32px]">
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {/* Client Selection */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Client *
            </label>
            {clientId ? (
              <div className="bg-white rounded-[12px] p-4 border-2 border-[#00a63e] flex items-center gap-3">
                {selectedClient && (
                  <>
                    <div
                      className="rounded-full size-[40px] flex items-center justify-center shrink-0"
                      style={{ backgroundColor: selectedClient.color }}
                    >
                      <p className="font-['Inter',sans-serif] font-semibold text-white text-[14px]">
                        {selectedClient.initials}
                      </p>
                    </div>
                    <div>
                      <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">
                        {selectedClient.name}
                      </p>
                      <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px] capitalize">
                        {selectedClient.type}
                      </p>
                    </div>
                  </>
                )}
              </div>
            ) : (
              <select
                value={formData.clientId}
                onChange={(e) => setFormData({ ...formData, clientId: e.target.value })}
                className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                required
              >
                <option value="">Select a client</option>
                {clients.filter(c => c.type === 'project').map(client => (
                  <option key={client.id} value={client.id}>
                    {client.name}
                  </option>
                ))}
              </select>
            )}
          </div>

          {/* Project Name */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Project Name *
            </label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g., Website Redesign"
              className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
              required
            />
          </div>

          {/* Amount */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Amount (€) *
            </label>
            <input
              type="number"
              value={formData.amount}
              onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
              placeholder="e.g., 2500"
              className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
              required
            />
          </div>

          {/* Deadline */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Deadline *
            </label>
            <input
              type="date"
              value={formData.deadline}
              onChange={(e) => setFormData({ ...formData, deadline: e.target.value })}
              className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
              required
            />
          </div>

          {/* Status */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Status *
            </label>
            <div className="flex flex-col gap-2">
              {(['in progress', 'waiting for feedback', 'completed'] as const).map(status => (
                <button
                  key={status}
                  type="button"
                  onClick={() => setFormData({ ...formData, status })}
                  className={`bg-white rounded-[12px] p-[16px] flex items-center gap-3 transition-all ${
                    formData.status === status
                      ? 'ring-2 ring-[#00a63e] shadow-md'
                      : 'shadow-sm border border-[#e5e5e5]'
                  }`}
                >
                  <div
                    className="size-4 rounded-full"
                    style={{
                      backgroundColor:
                        status === 'in progress' ? '#f4a526' :
                        status === 'waiting for feedback' ? '#ff6b6b' :
                        '#00a63e'
                    }}
                  />
                  <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[16px] capitalize">
                    {status}
                  </p>
                </button>
              ))}
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full bg-[#00a63e] text-white py-4 rounded-[16px] font-['Inter',sans-serif] font-semibold text-[16px] shadow-lg active:scale-[0.98] transition-transform mt-4"
          >
            Add Project
          </button>
        </form>
      </div>
    </>
  );
}
