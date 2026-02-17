// Ambient declarations for Deno and remote modules so the IDE type-checks this file.
// At runtime, Supabase Edge Functions run in Deno and resolve these natively.

declare const Deno: {
  env: { get(key: string): string | undefined };
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
};

declare module "npm:@supabase/supabase-js@2" {
  interface SupabaseClient {
    auth: {
      getUser(token: string): Promise<{ data: { user: { id: string } | null }; error: Error | null }>;
    };
    from(table: string): {
      select(columns: string): {
        eq(column: string, value: string | number): {
          gte(column: string, value: string): {
            order(column: string, options: { ascending: boolean }): Promise<{
              data: unknown;
              error: { message: string } | null;
            }>;
          };
        };
      };
    };
  }
  export function createClient(
    url: string,
    key: string,
    options?: { global?: { headers?: Record<string, string> } }
  ): SupabaseClient;
}

declare module "https://deno.land/x/openai@v4.24.0/mod.ts" {
  export default class OpenAI {
    constructor(options: { apiKey: string });
    chat: {
      completions: {
        create(options: {
          model: string;
          messages: Array<{ role: string; content: string }>;
          stream: boolean;
        }): Promise<{
          choices: Array<{ message?: { content?: string | null } }>;
        }>;
      };
    };
  }
}
