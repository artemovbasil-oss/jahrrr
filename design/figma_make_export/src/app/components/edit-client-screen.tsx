import React, { useState } from 'react';
import { useCRM, Client, Contact } from './crm-context';
import { ChevronLeft, Plus, X } from 'lucide-react';

type EditClientScreenProps = {
  clientId: string;
  onNavigate: (screen: string, data?: any) => void;
};

const COLORS = [
  '#77afca', '#e5e5e5', '#c9b5a8', '#f4a526', '#ff6b6b',
  '#00a63e', '#0369a1', '#ca8a04', '#9333ea', '#dc2626'
];

export function EditClientScreen({ clientId, onNavigate }: EditClientScreenProps) {
  const { getClient, updateClient } = useCRM();
  const client = getClient(clientId);

  const [formData, setFormData] = useState({
    name: client?.name || '',
    type: (client?.type || 'project') as 'retainer' | 'project',
    color: client?.color || COLORS[0],
    salary: client?.salary?.toString() || '',
    contacts: client?.contacts || [],
  });

  if (!client) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <p className="text-[#4a5565] text-[16px]">Client not found</p>
      </div>
    );
  }

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

    const updates: Partial<Client> = {
      name: formData.name,
      type: formData.type,
      initials: getInitials(formData.name),
      color: formData.color,
      contacts: formData.contacts,
      ...(formData.type === 'retainer' && formData.salary ? {
        salary: parseFloat(formData.salary),
      } : {}),
    };

    updateClient(clientId, updates);
    onNavigate('client', { clientId });
  };

  const addContact = () => {
    setFormData({
      ...formData,
      contacts: [
        ...formData.contacts,
        {
          id: Date.now().toString(),
          value: '',
          type: 'phone' as const,
        },
      ],
    });
  };

  const updateContact = (id: string, updates: Partial<Contact>) => {
    setFormData({
      ...formData,
      contacts: formData.contacts.map(c => c.id === id ? { ...c, ...updates } : c),
    });
  };

  const removeContact = (id: string) => {
    setFormData({
      ...formData,
      contacts: formData.contacts.filter(c => c.id !== id),
    });
  };

  return (
    <>
      {/* Header */}
      <div className="content-stretch flex items-center justify-between pb-0 pt-[16px] px-0 relative shrink-0 w-full">
        <div className="flex-[1_0_0] h-[48px] min-h-px min-w-px relative">
          <div className="flex flex-col justify-center size-full">
            <div className="content-stretch flex gap-[16px] h-[35.998px] items-center px-[15.998px] py-0 relative w-full">
              <button
                onClick={() => onNavigate('client', { clientId })}
                className="flex h-[20px] items-center justify-center relative shrink-0 w-[14px]"
              >
                <ChevronLeft className="size-6 text-[#4A5565]" strokeWidth={2} />
              </button>
              <p className="flex-[1_0_0] font-['Inter',sans-serif] font-semibold leading-[36px] min-h-px min-w-px text-[#101828] text-[30px] overflow-hidden text-ellipsis tracking-[0.3955px]">
                Edit Client
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

          {/* Contacts */}
          <div className="border-t border-[#e5e5e5] pt-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[18px]">
                Contacts
              </h3>
              <button
                type="button"
                onClick={addContact}
                className="flex items-center gap-1 text-[#00a63e] font-['Inter',sans-serif] font-medium text-[14px]"
              >
                <Plus className="size-4" />
                Add
              </button>
            </div>

            <div className="flex flex-col gap-3">
              {formData.contacts.map((contact, index) => (
                <div key={contact.id} className="bg-white rounded-[12px] border border-[#e5e5e5] p-3 flex flex-col gap-2">
                  <div className="flex items-center gap-2">
                    <select
                      value={contact.type}
                      onChange={(e) => updateContact(contact.id, { type: e.target.value as Contact['type'] })}
                      className="px-3 py-2 rounded-[8px] bg-gray-50 border border-[#e5e5e5] font-['Inter',sans-serif] text-[14px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                    >
                      <option value="name">Name</option>
                      <option value="phone">Phone</option>
                      <option value="email">Email</option>
                      <option value="social">Social</option>
                    </select>
                    <input
                      type="text"
                      value={contact.value}
                      onChange={(e) => updateContact(contact.id, { value: e.target.value })}
                      placeholder={contact.type === 'name' ? 'Full Name' : contact.type === 'phone' ? 'Phone Number' : contact.type === 'email' ? 'Email Address' : 'Social Handle'}
                      className="flex-1 px-3 py-2 rounded-[8px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[14px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                    />
                    <button
                      type="button"
                      onClick={() => removeContact(contact.id)}
                      className="p-2 text-[#ff6b6b] hover:bg-red-50 rounded-[8px] transition-colors"
                    >
                      <X className="size-4" />
                    </button>
                  </div>
                  {contact.type === 'name' && (
                    <input
                      type="text"
                      value={contact.role || ''}
                      onChange={(e) => updateContact(contact.id, { role: e.target.value })}
                      placeholder="Role (optional)"
                      className="w-full px-3 py-2 rounded-[8px] bg-white border border-[#e5e5e5] font-['Inter',sans-serif] text-[14px] focus:outline-none focus:ring-2 focus:ring-[#00a63e]"
                    />
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full bg-[#00a63e] text-white py-4 rounded-[16px] font-['Inter',sans-serif] font-semibold text-[16px] shadow-lg active:scale-[0.98] transition-transform mt-4"
          >
            Save Changes
          </button>
        </form>
      </div>
    </>
  );
}
