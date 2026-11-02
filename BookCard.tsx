import Link from 'next/link';
import { BookOpen, LockKeyhole } from 'lucide-react';
import type { Book } from '@/lib/types';
export default function BookCard({book}:{book:Book}) {
 return <article className="group overflow-hidden rounded-2xl border border-violet-100 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-glow">
  <Link href={`/book/${book.id}`} className="block">
   <div className="relative aspect-[3/4] overflow-hidden book-cover p-4">
    {book.cover_url ? <img src={book.cover_url} alt={`جلد ${book.title}`} className="absolute inset-0 h-full w-full object-cover transition duration-500 group-hover:scale-105"/> : <div className="relative flex h-full flex-col justify-between rounded-lg border border-white/30 p-4 text-white"><span className="text-[10px] tracking-widest">VAGHINO BOOKS</span><div><div className="mb-3 h-1 w-10 bg-gold"/><h3 className="text-xl font-extrabold leading-8">{book.title}</h3><p className="mt-2 text-xs text-white/70">{book.author_name || 'نویسنده ورقینو'}</p></div><BookOpen className="self-end text-gold" size={24}/></div>}
    <span className="absolute right-3 top-3 rounded-full bg-white/90 px-2.5 py-1 text-[11px] font-bold text-violet">{book.is_free || Number(book.price)===0?'رایگان':`${Number(book.price).toLocaleString('fa-IR')} تومان`}</span>
   </div>
   <div className="p-4"><div className="text-[11px] font-bold text-violet">{book.category}</div><h3 className="mt-1 line-clamp-1 font-extrabold text-ink">{book.title}</h3><p className="mt-1 line-clamp-2 min-h-10 text-xs leading-5 text-slate-500">{book.description}</p><div className="mt-3 flex items-center justify-between text-xs text-slate-400"><span>{book.author_name || 'نویسنده'}</span>{book.is_free?<BookOpen size={15}/>:<LockKeyhole size={15}/>}</div></div>
  </Link>
 </article>
}
