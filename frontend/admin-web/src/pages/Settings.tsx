import { PageHeader } from '@/components/shared/PageHeader';
import { useThemeStore } from '@/store/theme';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';

export const Settings = () => {
  const { theme, setTheme } = useThemeStore();

  return (
    <div className="space-y-6">
      <PageHeader 
        title="Settings" 
        description="Manage your account preferences and system settings."
      />

      <Card>
        <CardHeader>
          <CardTitle>Appearance</CardTitle>
          <CardDescription>
            Customize the look and feel of the admin dashboard.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Theme Preference</Label>
              <div className="flex gap-4">
                {(['light', 'dark', 'system'] as const).map((t) => (
                  <label key={t} className="flex items-center space-x-2 cursor-pointer">
                    <input
                      type="radio"
                      name="theme"
                      value={t}
                      checked={theme === t}
                      onChange={() => setTheme(t)}
                      className="form-radio text-primary"
                    />
                    <span className="capitalize">{t}</span>
                  </label>
                ))}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
