import re
def txt_wrap_by(start_str, end, html):
    start = html.find(start_str)
    if start >= 0:
        start += len(start_str)
        end = html.find(end, start)
        if end >= 0:
            return html[start:end].strip()

def txt_wrap_by_all(start_str, end, html):
        result = []
        from_pos = 0
        while True:
            start = html.find(start_str, from_pos)
            if start >= 0:
                start += len(start_str)
                endpos = html.find(end, start)
                if endpos >= 0:
                    result.append(html[start:endpos].strip())
                    from_pos = endpos+len(end)
                    continue
            break
        return result


def strip_txt_wrap_by(start, end, html):
    t = txt_wrap_by(start, end, html)
        if t:
        return strip_line(t)


def strip_line(txt):
    txt = txt.replace("　", " ").split("\n")
    return "\n".join(i for i in [i.strip() for i in txt] if i)
