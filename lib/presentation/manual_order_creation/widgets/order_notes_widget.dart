import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class OrderNotesWidget extends StatefulWidget {
  final String internalNotes;
  final ValueChanged<String> onNotesChanged;

  const OrderNotesWidget({
    super.key,
    required this.internalNotes,
    required this.onNotesChanged,
  });

  @override
  State<OrderNotesWidget> createState() => _OrderNotesWidgetState();
}

class _OrderNotesWidgetState extends State<OrderNotesWidget> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.internalNotes);
  }

  @override
  void didUpdateWidget(OrderNotesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.internalNotes != oldWidget.internalNotes) {
      _notesController.text = widget.internalNotes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.note_add,
                size: 3.h,
                color: Color(0xFF8B4513),
              ),
              SizedBox(width: 2.w),
              Text(
                'Observações Internas',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Description
          Text(
            'Anotações visíveis apenas para a equipe interna. O cliente não verá essas informações.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 3.h),

          // Notes Field
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration(
              'Ex: Cliente especial, atenção ao horário, produto personalizado...',
            ),
            style: GoogleFonts.inter(fontSize: 14.sp),
            maxLines: 4,
            onChanged: widget.onNotesChanged,
          ),

          SizedBox(height: 3.h),

          // Quick Notes
          Text(
            'Anotações Rápidas:',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _buildQuickNoteChip('Cliente VIP'),
              _buildQuickNoteChip('Primeira compra'),
              _buildQuickNoteChip('Pedido especial'),
              _buildQuickNoteChip('Atenção ao horário'),
              _buildQuickNoteChip('Cliente frequente'),
              _buildQuickNoteChip('Produto personalizado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNoteChip(String note) {
    return GestureDetector(
      onTap: () {
        debugPrint('=== QUICK NOTE CHIP TAPPED: $note ===');
        String currentNotes = _notesController.text.trim();
        debugPrint('Current notes: "$currentNotes"');

        String newNotes;
        if (currentNotes.isEmpty) {
          newNotes = note;
          debugPrint('Adding first note: "$newNotes"');
        } else if (!currentNotes.contains(note)) {
          newNotes = '$currentNotes; $note';
          debugPrint('Appending note: "$newNotes"');
        } else {
          debugPrint('Note already exists, skipping');
          return;
        }

        _notesController.text = newNotes;
        widget.onNotesChanged(newNotes);
        debugPrint('=== NOTE CALLBACK EXECUTED ===');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 1.5.h,
              color: Colors.blue[600],
            ),
            SizedBox(width: 1.w),
            Text(
              note,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        color: Colors.grey[400],
      ),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
    );
  }
}
