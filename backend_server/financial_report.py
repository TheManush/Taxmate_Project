from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from financial_crud import get_financial_data, calculate_financial_summary
import tempfile
from fpdf import FPDF
import os

router = APIRouter()

def generate_financial_report_pdf(client_id: int) -> str:
    data = get_financial_data(client_id)
    if not data:
        raise HTTPException(status_code=404, detail="No financial data found for this client.")
    summary = calculate_financial_summary(data)
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", 'B', 18)
    pdf.set_text_color(40, 40, 120)
    pdf.cell(0, 12, txt="Comprehensive Financial Life Report", ln=True, align="C")
    pdf.set_font("Arial", size=12)
    pdf.set_text_color(0, 0, 0)
    pdf.ln(8)
    pdf.cell(0, 10, txt=f"Client ID: {client_id}", ln=True)
    pdf.ln(4)
    pdf.set_font("Arial", 'B', 14)
    pdf.cell(0, 10, txt="Your Financial Data Overview", ln=True)
    pdf.set_font("Arial", size=12)
    pdf.set_fill_color(230, 240, 255)
    for k, v in data.items():
        label = k.replace('_', ' ').title()
        value = v if v != '' else 'N/A'
        pdf.cell(80, 8, txt=label, border=0, fill=True)
        pdf.cell(0, 8, txt=str(value), ln=True, border=0, fill=True)
    pdf.ln(8)
    pdf.set_font("Arial", 'B', 14)
    pdf.cell(0, 10, txt="Financial Summary & Insights", ln=True)
    pdf.set_font("Arial", size=12)
    for k, v in summary.items():
        label = k.replace('_', ' ').title()
        pdf.cell(80, 8, txt=label, border=0)
        pdf.cell(0, 8, txt=str(round(v, 2)), ln=True, border=0)
    pdf.ln(8)
    pdf.set_font("Arial", 'I', 12)
    pdf.set_text_color(80, 80, 80)
    pdf.multi_cell(0, 8, txt="This report is designed to help you understand your financial life, spot opportunities, and make informed decisions. For personalized advice, consult with a professional financial planner.")
    temp = tempfile.NamedTemporaryFile(delete=False, suffix=".pdf")
    pdf.output(temp.name)
    return temp.name

@router.get("/financial-report/{client_id}")
def download_financial_report(client_id: int):
    pdf_path = generate_financial_report_pdf(client_id)
    if not os.path.exists(pdf_path):
        raise HTTPException(status_code=500, detail="PDF generation failed.")
    return FileResponse(pdf_path, media_type="application/pdf", filename=f"financial_report_{client_id}.pdf")
