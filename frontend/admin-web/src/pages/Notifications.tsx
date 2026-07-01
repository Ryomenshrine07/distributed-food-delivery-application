import { PageHeader } from '@/components/shared/PageHeader';
import { PendingFeature } from '@/components/shared/PendingFeature';
import { Button } from '@/components/ui/button';

export const Notifications = () => {
  return (
    <div>
      <PageHeader 
        title="Global Notifications" 
        description="Send broadcast messages to customers, restaurants, or drivers."
        action={<Button>Compose Message</Button>}
      />
      <PendingFeature 
        title="Push Notification Service Missing" 
        description="The admin endpoints to dispatch global Firebase Cloud Messaging (FCM) notifications are not implemented (Gap 8)."
      />
    </div>
  );
};
