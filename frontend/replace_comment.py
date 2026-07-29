
import sys
c = open('lib/features/jobs/screens/candidate_job_details_screen.dart', 'r', encoding='utf-8').read()

old_str = '''    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFEEEBF4),
          width: widget.isExpanded ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.isExpanded
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -4,
                ),
              ]
            : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ['''

new_str = '''    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFEEEBF4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.isExpanded
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -4,
                ),
              ]
            : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: widget.isExpanded
                  ? const Border(bottom: BorderSide(color: Color(0x4DE7E0E7)))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ['''

old_str_crlf = old_str.replace('\n', '\r\n')
new_str_crlf = new_str.replace('\n', '\r\n')

if old_str in c:
    c = c.replace(old_str, new_str, 1)
    open('lib/features/jobs/screens/candidate_job_details_screen.dart', 'w', encoding='utf-8').write(c)
    print('Replaced with LF')
elif old_str_crlf in c:
    c = c.replace(old_str_crlf, new_str_crlf, 1)
    open('lib/features/jobs/screens/candidate_job_details_screen.dart', 'w', encoding='utf-8').write(c)
    print('Replaced with CRLF')
else:
    print('Not found')

