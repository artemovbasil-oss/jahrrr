import React, { useState } from 'react';
import { useCRM } from './crm-context';
import { ChevronLeft, Calendar, DollarSign, Trash2, MoreVertical, Edit, Copy, Archive } from 'lucide-react';

type ProjectDetailScreenProps = {
  projectId: string;
  onNavigate: (screen: string, data?: any) => void;
};

export function ProjectDetailScreen({ projectId, onNavigate }: ProjectDetailScreenProps) {
  const { projects, getClient, updateProject, deleteProject, addProject } = useCRM();
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showMenu, setShowMenu] = useState(false);

  const project = projects.find(p => p.id === projectId);
  const client = project ? getClient(project.clientId) : null;

  if (!project || !client) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <p className="text-[#4a5565] text-[16px]">Project not found</p>
      </div>
    );
  }

  const handleStatusChange = (status: typeof project.status) => {
    updateProject(project.id, { status });
  };

  const handleDelete = () => {
    deleteProject(project.id);
    onNavigate('client', { clientId: client.id });
  };

  const handleDuplicate = () => {
    const duplicatedProject = {
      ...project,
      name: `${project.name} (Copy)`,
    };
    delete (duplicatedProject as any).id;
    addProject(duplicatedProject);
    setShowMenu(false);
  };

  const handleArchive = () => {
    // In a real app, you'd set archived status
    updateProject(projectId, { status: 'completed' });
    setShowMenu(false);
    onNavigate('client', { clientId: client.id });
  };

  const statusColors: Record<typeof project.status, string> = {
    'in progress': '#f4a526',
    'waiting for feedback': '#ff6b6b',
    'completed': '#00a63e',
  };

  return (
    <>
      {/* Header */}
      <div className="content-stretch flex items-center justify-between pb-0 pt-[16px] px-0 relative shrink-0 w-full">
        <div className="flex-[1_0_0] h-[48px] min-h-px min-w-px relative">
          <div className="flex flex-col justify-center size-full">
            <div className="content-stretch flex gap-[16px] h-[35.998px] items-center px-[15.998px] py-0 relative w-full">
              <button
                onClick={() => onNavigate('client', { clientId: client.id })}
                className="flex h-[20px] items-center justify-center relative shrink-0 w-[14px]"
              >
                <ChevronLeft className="size-6 text-[#4A5565]" strokeWidth={2} />
              </button>
              <p className="flex-[1_0_0] font-['Inter',sans-serif] font-semibold leading-[36px] min-h-px min-w-px text-[#101828] text-[24px] overflow-hidden text-ellipsis tracking-[0.3955px]">
                {project.name}
              </p>
            </div>
          </div>
        </div>
        <div className="content-stretch flex items-center gap-2 px-[16px] py-0 relative shrink-0">
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
                      onNavigate('edit-project', { projectId });
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
                  <button
                    onClick={() => {
                      setShowMenu(false);
                      setShowDeleteConfirm(true);
                    }}
                    className="w-full px-4 py-3 flex items-center gap-3 hover:bg-red-50 transition-colors border-t border-gray-100"
                  >
                    <Trash2 className="size-5 text-[#ff6b6b]" />
                    <span className="font-['Inter',sans-serif] font-medium text-[#ff6b6b] text-[15px]">Delete</span>
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      </div>

      {/* Client Info */}
      <div className="px-[16px] pt-[24px]">
        <div className="bg-white rounded-[16px] shadow-sm p-[16px] flex items-center gap-3">
          <div
            className="rounded-full size-[48px] flex items-center justify-center shrink-0"
            style={{ backgroundColor: client.color }}
          >
            <p className="font-['Inter',sans-serif] font-semibold text-white text-[16px]">
              {client.initials}
            </p>
          </div>
          <div className="flex-1">
            <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[16px]">{client.name}</p>
            <p className="font-['Inter',sans-serif] font-normal text-[#4a5565] text-[14px] capitalize">{client.type}</p>
          </div>
        </div>
      </div>

      {/* Project Details */}
      <div className="px-[16px] pt-[24px]">
        <h3 className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px] mb-4">
          Project Details
        </h3>

        <div className="flex flex-col gap-3">
          {/* Amount */}
          <div className="bg-white rounded-[16px] shadow-sm p-[20px] flex items-center gap-4">
            <div className="bg-[#e5f4ff] rounded-full size-[48px] flex items-center justify-center shrink-0">
              <DollarSign className="size-6 text-[#0369a1]" />
            </div>
            <div className="flex-1">
              <p className="font-['Inter',sans-serif] font-medium text-[#4a5565] text-[14px]">Amount</p>
              <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[24px]">€{project.amount.toLocaleString()}</p>
            </div>
          </div>

          {/* Deadline */}
          <div className="bg-white rounded-[16px] shadow-sm p-[20px] flex items-center gap-4">
            <div className="bg-[#fef3e7] rounded-full size-[48px] flex items-center justify-center shrink-0">
              <Calendar className="size-6 text-[#f4a526]" />
            </div>
            <div className="flex-1">
              <p className="font-['Inter',sans-serif] font-medium text-[#4a5565] text-[14px]">Deadline</p>
              <p className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[18px]">
                {new Date(project.deadline).toLocaleDateString('en-US', { 
                  month: 'long', 
                  day: 'numeric', 
                  year: 'numeric' 
                })}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Status */}
      <div className="px-[16px] pt-[24px]">
        <h3 className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px] mb-4">
          Status
        </h3>

        <div className="flex flex-col gap-2">
          {(['in progress', 'waiting for feedback', 'completed'] as const).map(status => (
            <button
              key={status}
              onClick={() => handleStatusChange(status)}
              className={`bg-white rounded-[12px] p-[16px] flex items-center justify-between transition-all ${
                project.status === status
                  ? 'ring-2 ring-[#00a63e] shadow-md'
                  : 'shadow-sm'
              }`}
            >
              <div className="flex items-center gap-3">
                <div
                  className="size-4 rounded-full"
                  style={{ backgroundColor: statusColors[status] }}
                />
                <p className="font-['Inter',sans-serif] font-medium text-[#101828] text-[16px] capitalize">
                  {status}
                </p>
              </div>
              {project.status === status && (
                <div className="size-6 rounded-full bg-[#00a63e] flex items-center justify-center">
                  <div className="size-2 bg-white rounded-full" />
                </div>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-end z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-t-[24px] w-full p-[24px] animate-in slide-in-from-bottom duration-300">
            <div className="w-[40px] h-[4px] bg-[#e5e5e5] rounded-full mx-auto mb-6" />
            <h3 className="font-['Inter',sans-serif] font-semibold text-[#101828] text-[20px] mb-2">
              Delete Project
            </h3>
            <p className="font-['Inter',sans-serif] text-[#4a5565] text-[16px] mb-6">
              Are you sure you want to delete "{project.name}"? This action cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                className="flex-1 bg-[#e5e5e5] text-[#101828] py-4 rounded-[16px] font-['Inter',sans-serif] font-semibold text-[16px] active:scale-[0.98] transition-transform"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="flex-1 bg-[#ff6b6b] text-white py-4 rounded-[16px] font-['Inter',sans-serif] font-semibold text-[16px] active:scale-[0.98] transition-transform"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}