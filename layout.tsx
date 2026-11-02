import type { Metadata } from 'next';
import './globals.css';
import Link from 'next/link';
import { BookOpen, Search, UserRound, Sparkles } from 'lucide-react';
export const metadata: Metadata = { title: 'ورقینو | دنیای کتاب‌های دیجیتال', description: 'کتاب بخوان، کشف کن و داستانت را منتشر کن.' };
export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) {
 return <html lang="fa" dir="rtl"><body>
  <header className="sticky top-0 z-30 border-b border-violet-100/70 bg-paper/90 backdrop-blur-xl">
   <div className="container-app flex h-[76px] items-center justify-between gap-4">
    <Link href="/" className="flex items-center gap-2 text-xl font-extrabold text-ink"><span className="grid h-11 w-11 place-items-center rounded-2xl bg-violet text-white shadow-glow"><BookOpen size={23}/></span><span>ورقینو<span className="text-violet">.</span><small className="mr-2 hidden text-xs font-medium text-slate-500 sm:inline">قصه‌ها اینجا زنده‌اند</small></span></Link>
    <nav className="hidden items-center gap-6 text-sm font-semibold text-slate-600 md:flex"><Link href="/">کتابخانه</Link><a href="/#categories">دسته‌بندی‌ها</a><Link href="/dashboard">پنل نویسنده</Link><Link href="/admin">مدیریت</Link></nav>
    <div className="flex items-center gap-2"><Link href="/#catalog" aria-label="جست‌وجو" className="grid h-10 w-10 place-items-center rounded-xl border border-violet-100 bg-white text-violet"><Search size={19}/></Link><Link href="/login" className="flex items-center gap-2 rounded-xl bg-ink px-4 py-2.5 text-sm font-bold text-white hover:bg-violet"><UserRound size={17}/><span>ورود</span></Link></div>
   </div>
  </header>
  <main>{children}</main>
  <footer className="mt-20 border-t border-violet-100 bg-white/70"><div className="container-app flex flex-col gap-4 py-8 sm:flex-row sm:items-center sm:justify-between"><div><div className="font-extrabold text-ink">ورقینو ✦</div><p className="mt-1 text-sm text-slate-500">خانه‌ای برای داستان‌هایی که باید خوانده شوند.</p></div><div className="flex gap-4 text-sm text-slate-500"><Link href="/dashboard">انتشار کتاب</Link><Link href="/terms">قوانین</Link><Link href="/privacy">حریم خصوصی</Link></div></div></footer>
 </body></html>;
}
