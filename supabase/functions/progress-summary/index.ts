// Progress summary Edge Function: fetches last 7 days of workouts, calls OpenAI as personal trainer, returns summary.
/// <reference path="./deno.d.ts" />
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import OpenAI from "https://deno.land/x/openai@v4.24.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface WorkoutRow {
  id?: string;
  user_id?: string;
  type: string;
  duration_min: number;
  intensity: number;
  mood_before: number;
  mood_after: number;
  notes: string | null;
  created_at: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return Response.json(
        { error: "Missing or invalid Authorization header" },
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    const token = authHeader.replace("Bearer ", "");

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseAnonKey) {
      return Response.json(
        { error: "Server misconfiguration: missing Supabase key" },
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: `Bearer ${token}` } },
    });

    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return Response.json(
        { error: "Invalid or expired token" },
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const fromIso = sevenDaysAgo.toISOString();

    const { data: workouts, error: fetchError } = await supabase
      .from("workouts")
      .select("type, duration_min, intensity, mood_before, mood_after, notes, created_at")
      .eq("user_id", user.id)
      .gte("created_at", fromIso)
      .order("created_at", { ascending: false });

    if (fetchError) {
      return Response.json(
        { error: "Failed to fetch workouts: " + fetchError.message },
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const rows = (workouts ?? []) as WorkoutRow[];
    if (rows.length === 0) {
      return Response.json(
        {
          summary:
            "You don't have any workouts in the last 7 days. Log a few sessions, then come back for a progress summary—I'll help you see what's working for your mood and energy.",
        },
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openaiKey) {
      return Response.json(
        { error: "Server misconfiguration: missing OpenAI API key" },
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const openai = new OpenAI({ apiKey: openaiKey });
    const workoutDataText = JSON.stringify(
      rows.map((w) => ({
        type: w.type,
        duration_min: w.duration_min,
        intensity: w.intensity,
        mood_before: w.mood_before,
        mood_after: w.mood_after,
        mood_delta: w.mood_after - w.mood_before,
        notes: w.notes ?? "",
        date: w.created_at,
      })),
      null,
      2
    );

    const systemPrompt = `You are a supportive personal trainer. The user will receive a JSON array of their workouts from the past 7 days. Each workout has: type, duration_min, intensity, mood_before, mood_after, mood_delta, notes, and date.

Write a concise progress summary (2–4 short paragraphs) that:
1. Summarizes how different workout types affect their mood (which tend to improve or lower it).
2. Notes what seems to be working well for them and what might not be.
3. Ends with 1–2 short, actionable suggestions.

Be encouraging and specific to the data. Do not make up numbers or workouts. If there are few data points, say so and still give brief, useful feedback.`;

    const chatCompletion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: `Workouts from the last 7 days:\n\n${workoutDataText}` },
      ],
      stream: false,
    });

    const summary =
      chatCompletion.choices[0]?.message?.content?.trim() ||
      "I couldn't generate a summary this time. Try again in a moment.";

    return Response.json(
      { summary },
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return Response.json(
      { error: e instanceof Error ? e.message : "Unknown error" },
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
