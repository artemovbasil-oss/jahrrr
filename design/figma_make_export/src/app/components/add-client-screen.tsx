import React, { useState } from 'react';
import { useCRM, Client } from './crm-context';
import { ChevronLeft } from 'lucide-react';

type AddClientScreenProps = {
  onNavigate: (screen: string, data?: any) => void;
};

const COLORS = [
  '#77afca', '#e5e5e5', '#c9b5a8', '#f4a526', '#ff6b6b',
  '#00a63e', '#0369a1', '#ca8a04', '#9333ea', '#dc2626'
];

export function AddClientScreen({ onNavigate }: AddClientScreenProps) {
  const { addClient } = useCRM();
  const [formData, setFormData] = useState({
    name: '',
    type: 'project' as 'retainer' | 'project',
    color: COLORS[0],
    salary: '',
    contactName: '',
    contactRole: '',
    phone: '',
    email: '',
  });

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(word => word[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.name) return;

    const contacts = [];
    if (formData.contactName) {
      contacts.push({
        id: Date.now().toString(),
        name: formData.contactName,
        role: formData.contactRole,
        value: formData.contactName,
        type: 'name' as const,
      });
    }
    if (formData.phone) {
      contacts.push({
        id: (Date.now() + 1).toString(),
        value: formData.phone,
        type: 'phone' as const,
        isPreferred: true,
      });
    }
    if (formData.email) {
      contacts.push({
        id: (Date.now() + 2).toString(),
        value: formData.email,
        type: 'email' as const,
      });
    }

    const newClient: Omit<Client, 'id'> = {
      name: formData.name,
      type: formData.type,
      initials: getInitials(formData.name),
      color: formData.color,
      contacts,
      ...(formData.type === 'retainer' && formData.salary ? {
        salary: parseFloat(formData.salary),
        payments: 0,
      } : {
        inProgress: 0,
        totalAmount: 0,
      }),
    };

    addClient(newClient);
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
                New Client
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto px-[16px] pt-[32px] pb-[32px]">
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          {/* Preview Avatar */}
          <div className="flex flex-col items-center gap-4 py-4">
            <div
              className="rounded-full size-[80px] flex items-center justify-center shadow-lg"
              style={{ backgroundColor: formData.color }}
            >
              <p className="font-['Inter',sans-serif] font-semibold text-white text-[32px]">
                {formData.name ? getInitials(formData.name) : '?'}
              </p>
            </div>
            
            {/* Color Picker */}
            <div className="flex gap-2 flex-wrap justify-center">
              {COLORS.map(color => (
                <button
                  key={color}
                  type="button"
                  onClick={() => setFormData({ ...formData, color })}
                  className={`size-8 rounded-full transition-transform ${
                    formData.color === color ? 'ring-4 ring-offset-2 ring-[#00a63e] scale-110' : ''
                  }`}
                  style={{ backgroundColor: color }}
                />
              ))}
            </div>
          </div>

          {/* Client Name */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Client Name *
            </label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g., Acme Corporation"
              className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
              required
            />
          </div>

          {/* Client Type */}
          <div>
            <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
              Client Type *
            </label>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setFormData({ ...formData, type: 'project' })}
                className={`flex-1 px-4 py-3 rounded-[12px] font-['Inter',sans-serif] font-medium text-[16px] transition-colors ${
                  formData.type === 'project'
                    ? 'bg-[#00a63e] text-white'
                    : 'bg-white text-[#4a5565] border border-[#e5e5e5]'
                }`}
              >
                Project
              </button>
              <button
                type="button"
                onClick={() => setFormData({ ...formData, type: 'retainer' })}
                className={`flex-1 px-4 py-3 rounded-[12px] font-['Inter',sans-serif] font-medium text-[16px] transition-colors ${
                  formData.type === 'retainer'
                    ? 'bg-[#00a63e] text-white'
                    : 'bg-white text-[#4a5565] border border-[#e5e5e5]'
                }`}
              >
                Retainer
              </button>
            </div>
          </div>

          {/* Salary (if retainer) */}
          {formData.type === 'retainer' && (
            <div>
              <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
                Monthly Salary (€)
              </label>
              <input
                type="number"
                value={formData.salary}
                onChange={(e) => setFormData({ ...formData, salary: e.target.value })}
                placeholder="e.g., 3500"
                className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
              />
            </div>
          )}

          {/* Contact Information */}
          <div className="border-t border-[#e5e5e5] pt-6">
            <h3 className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[18px] mb-4">
              Contact Information
            </h3>

            <div className="flex flex-col gap-4">
              <div>
                <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
                  Contact Name
                </label>
                <input
                  type="text"
                  value={formData.contactName}
                  onChange={(e) => setFormData({ ...formData, contactName: e.target.value })}
                  placeholder="e.g., John Doe"
                  className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                />
              </div>

              <div>
                <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
                  Role
                </label>
                <input
                  type="text"
                  value={formData.contactRole}
                  onChange={(e) => setFormData({ ...formData, contactRole: e.target.value })}
                  placeholder="e.g., CEO"
                  className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                />
              </div>

              <div>
                <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
                  Phone
                </label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  placeholder="e.g., +1 234 567 8900"
                  className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                />
              </div>

              <div>
                <label className="font-['Inter',sans-serif] font-medium text-[#101828] text-[14px] mb-2 block">
                  Email
                </label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="e.g., john@example.com"
                  className="w-full px-4 py-3 rounded-[12px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[16px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                />
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full bg-[#00a63e] text-white py-4 rounded-[16px] font-['Inter',sans-serif] font-semibold text-[16px] shadow-lg active:scale-[0.98] transition-transform mt-4"
          >
            Add Client
          </button>
        </form>
      </div>
    </>
  );
}
